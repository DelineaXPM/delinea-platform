import subprocess
import json
import datetime
import time
import requests
from colorama import init, Fore, Style
from config import (
    AZURE_TENANT_ID, PLATFORM_URL, PLATFORM_CLIENT_ID, PLATFORM_CLIENT_SECRET, APP_NAME, DOMAIN_NAMES,
    AZURE_SECRET_DURATION_MONTHS, AZURE_SECRET_DISPLAY_NAME, AZURE_GRAPH_API_ID,
    PLATFORM_SCOPE, PLATFORM_GRANT_TYPE, PLATFORM_REG_APP_DESC
)

# Initialize colorama
init(autoreset=True)

def run_command(command, error_message):
    """Run a CLI command and return the output."""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"{error_message}\nCommand: {command}\nError: {result.stderr.strip()}")
        return result.stdout.strip()
    except Exception as ex:
        raise Exception(f"Failed to execute command: {ex}")

def calculate_secret_expiration(duration_months):
    """Calculate the secret expiration date."""
    return (datetime.datetime.now() + datetime.timedelta(days=30 * duration_months)).isoformat()

def app_exists(APP_NAME):
    """Check if an app with the specified name exists."""
    output = run_command(
        f"az ad app list --filter \"displayName eq '{APP_NAME}'\" --query '[].appId' -o tsv",
        f"Failed to check if app '{APP_NAME}' exists."
    )
    return bool(output)

def log(message, color=Fore.WHITE):
    """Log messages with color."""
    print(color + message + Style.RESET_ALL)

# Function to get a bearer token from Delinea Platform
def get_bearer_token():
    # Prepare payload and headers for the token request
    payload = {
        "client_id": PLATFORM_CLIENT_ID,
        "client_secret": PLATFORM_CLIENT_SECRET,
        "grant_type": PLATFORM_GRANT_TYPE,
        "scope": PLATFORM_SCOPE
    }
    
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }
    
    # Make the request to get the bearer token
    url =f"{PLATFORM_URL}/identity/api/oauth2/token/xpmplatform"
    response = requests.post(url, data=payload, headers=headers)
    
    if response.status_code == 200:
        token_data = response.json()
        return token_data['access_token']
    else:
        log(f"Error: {response.status_code} - {response.text}", Fore.RED)
        return None

# Function to create the registered application in Delinea platform
def create_registered_app(bearer_token, app_id, secret_value, secret_end_date, tenant_id):
    # Prepare payload for creating the registered app
    payload = {
        "name": APP_NAME,
        "description": PLATFORM_REG_APP_DESC,
        "addNewDomainControl": "",
        "externalTenantId": tenant_id,
        "applicationDefinitionIds": [
            "azure-entra-read",
            "azure-entra-login"
        ],
        "clientId": app_id,
        "clientSecret": secret_value,
        "credentialExpiresAt": int(datetime.datetime.strptime(secret_end_date, "%Y-%m-%dT%H:%M:%SZ").timestamp()),  # Convert expiry to Unix timestamp
        "domainNames": [
            DOMAIN_NAMES
        ],
        "enabledState": "Enabled",
        "vendor": "Azure",
        "provisionDirectoryServices": True
    }

    # Set authorization header with bearer token
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    # Make the request to create the registered app
    url =f"{PLATFORM_URL}/registration/api/registrations/application"
    response = requests.post(url, json=payload, headers=headers)

    if response.status_code != 200:
        log(f"Failed to create registered app: {response.status_code} - {response.text}", Fore.RED)
        response.raise_for_status()

    return response.json()

def get_registration_details(bearer_token, registration_id):
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    url = f"{PLATFORM_URL}/registration/api/registrations/application/{registration_id}"
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        log(f"Failed to get registration details: {response.status_code} - {response.text}", Fore.RED)
        response.raise_for_status()

    return response.json()

def get_federation_profile(bearer_token, federation_profile_id):
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    url = f"{PLATFORM_URL}/identity-federation/api/oidc-providers/{federation_profile_id}"
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        log(f"Failed to get Federation provider: {response.status_code} - {response.text}", Fore.RED)
        response.raise_for_status()

    return response.json()

def add_redirect_uri(app_id, callback_url):
    command = [
        "az", "ad", "app", "update",
        "--id", app_id,
        "--web-redirect-uris", callback_url
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        log(f"Failed to add redirect URI: {result.stderr}", Fore.RED)
        raise Exception(result.stderr)
    log(f"Redirect URI added to Azure App: {callback_url}", Fore.GREEN)

try:
    # Section: Authenticate to Azure
    log("\n=== Authenticating to Azure ===", Fore.CYAN)
    try:
        run_command(f"az login --tenant {AZURE_TENANT_ID} --allow-no-subscriptions", "Failed to authenticate to Azure.")
        log("Successfully authenticated to Azure.", Fore.GREEN)
    except Exception as e:
        log(f"Failed to authenticate to Azure: {e}", Fore.RED)
        exit(1)

    # Section: Fetch Tenant ID
    log("\n=== Fetching Tenant ID ===", Fore.CYAN)
    try:
        tenant_id = run_command("az account show --query tenantId -o tsv", "Failed to fetch Tenant ID.")
        log(f"Tenant ID: {tenant_id}", Fore.GREEN)
    except Exception as e:
        log(f"Failed to fetch Tenant ID: {e}", Fore.RED)
        exit(1)

    # Section: Check if the app already exists
    log("\n=== Checking if App Exists ===", Fore.CYAN)
    if app_exists(APP_NAME):
        log(f"App '{APP_NAME}' already exists. Skipping creation.", Fore.YELLOW)
        exit(1)
    else:
        log(f"App '{APP_NAME}' does not exist. Proceeding with creation.", Fore.GREEN)

    # Section: Create App Registration
    log("\n=== Creating App Registration ===", Fore.CYAN)
    app_id = run_command(
        f"az ad app create --display-name \"{APP_NAME}\" --query appId -o tsv",
        "Failed to create App Registration."
    )
    log(f"App Registration created. Application (Client) ID: {app_id}", Fore.GREEN)

    # Section: Create Client Secret
    log("\n=== Creating Client Secret ===", Fore.CYAN)
    expiration_date = calculate_secret_expiration(AZURE_SECRET_DURATION_MONTHS)
    secret_output = run_command(
        f"az ad app credential reset --id {app_id} --append --end-date {expiration_date} "
        f"--display-name '{AZURE_SECRET_DISPLAY_NAME}' --query '{{\"secretValue\":password}}' -o json",
        "Failed to create client secret."
    )
    secret_data = json.loads(secret_output)
    secret_value = secret_data.get("secretValue")
    log(f"Client Secret Value: {secret_value} (Save securely!)", Fore.GREEN)

    # Allow Azure time to bootstrap
    log("Sleeping for 5 seconds to allow Azure time to bootstrap...", Fore.YELLOW)
    time.sleep(5)

    # Section: Fetch and parse credentials
    log("\n=== Fetching Credentials to Verify Secret Expiration Date ===", Fore.CYAN)
    credentials_output = run_command(
        f"az ad app credential list --id {app_id} -o json",
        "Failed to fetch credentials."
    )
    credentials_data = json.loads(credentials_output)
    secret_end_date = next(
        (
            datetime.datetime.fromisoformat(cred['endDateTime'].replace('Z', '+00:00')).strftime('%Y-%m-%dT%H:%M:%SZ')
            for cred in credentials_data if 'endDateTime' in cred
        ),
        None
    )
    log(f"Credential Expiration Date: {secret_end_date or 'Not found'}", Fore.GREEN)

    # Section: Configure Optional Claims
    log("\n=== Configuring Optional Claims (email, upn) ===", Fore.CYAN)
    optional_claims_config = {
        "optionalClaims": {
            "idToken": [
                {"name": "email", "essential": True},
                {"name": "upn", "essential": True}
            ]
        }
    }
    app_object_id = run_command(f"az ad app show --id {app_id} --query id -o tsv", "Failed to retrieve App Object ID.")
    run_command(
        f"az rest --method PATCH --uri https://graph.microsoft.com/v1.0/applications/{app_object_id} "
        f"--headers 'Content-Type=application/json' --body '{json.dumps(optional_claims_config)}'",
        "Failed to configure optional claims."
    )
    log("Optional claims configured.", Fore.GREEN)

    # Section: Configure Permissions
    log("\n=== Configuring Permissions ===", Fore.CYAN)
    permissions = {
        "Delegated": {
            "email": "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0",
            "profile": "14dad69e-099b-42c9-810b-d002981feec1",
            "User.Read": "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
        },
        "Application": {
            "AuditLog.Read.All": "b0afded3-3588-46d8-8b3d-9842eff778da",
            "Group.Read.All": "5b567255-7703-4780-807c-7be8301ae99b",
            "GroupMember.Read.All": "98830695-27a2-44f7-8c18-0c3ebc9698f6",
            "Member.Read.Hidden": "658aa5d8-239f-45c4-aa12-864f4fc7e490",
            "User.Read.All": "df021288-bdef-4463-88db-98f22de89214"
        }
    }

    for perm_type, perm_dict in permissions.items():
        log(f"Configuring {perm_type.lower()} permissions...", Fore.CYAN)
        for permission, guid in perm_dict.items():
            run_command(
                f"az ad app permission add --id {app_id} --api {AZURE_GRAPH_API_ID} --api-permissions {guid}="
                f"{'Scope' if perm_type == 'Delegated' else 'Role'}",
                f"Failed to add {perm_type.lower()} permission: {permission}."
            )
        log(f"{perm_type} permissions configured.", Fore.GREEN)

    # Section: Grant Admin Consent
    log("\n=== Granting admin consent  ===", Fore.CYAN)
    animation = "|/-\\"
    idx = 0
    for perm_type, perm_dict in permissions.items():
        for guid in perm_dict.values():
            run_command(
                f"az ad app permission admin-consent --id {app_id}",
                f"Failed to grant admin consent."
            )
            # Display animation
            print(f"\rGranting admin consent... {animation[idx % len(animation)]}", end="")
            idx += 1
            time.sleep(0.1)  # Adjust the sleep time as needed
    log(f"\rAdmin consent granted.          ", Fore.GREEN)

    # Section: Azure AD Final Output
    log("\n=== Azure AD App Registration Created Successfully ===", Fore.CYAN)
    log(f"Directory (Tenant) ID: {tenant_id}", Fore.GREEN)
    log(f"Application (Client) ID: {app_id}", Fore.GREEN)
    log(f"Client Secret Value: {secret_value}", Fore.GREEN)
    log(f"Credential Expiration Date: {secret_end_date}", Fore.GREEN)

    # Section: Authenticate to Delinea Platform
    log("\n=== Authenticating to Delinea Platform ===", Fore.CYAN)
    bearer_token = get_bearer_token()
    
    if bearer_token:
        log("Successfully authenticated to Delinea Platform.", Fore.GREEN)
        
        # Section: Create App in Delinea Platform
        log("\n=== Creating the Registered App in Delinea Platform ===", Fore.CYAN)
        response = create_registered_app(bearer_token, app_id, secret_value, secret_end_date, tenant_id)
        log(f"Response: {response}", Fore.GREEN)

        # Allow Platform time to bootstrap
        log("Sleeping for 10 seconds to allow Platform time to bootstrap...", Fore.YELLOW)
        time.sleep(10)

        registration_id = response.get("registrationId")
        if registration_id:
            registration_details = get_registration_details(bearer_token, registration_id)
            log(f"Registration Details: {registration_details}", Fore.GREEN)

            federation_profile_id = registration_details.get("federationProfileId")
            if federation_profile_id:
                federation_profile = get_federation_profile(bearer_token, federation_profile_id)
                log(f"Federation provider: {federation_profile}", Fore.GREEN)

                callback_url = federation_profile.get("callbackUrl")
                if callback_url:
                    log(f"Retrieved Callback URL: {callback_url}", Fore.GREEN)
                    
                    # Section: Update Azure App with Redirect URI
                    log("\n=== Updating Azure App with Redirect URI ===", Fore.CYAN)
                    add_redirect_uri(app_id, callback_url)
                else:
                    log("Callback URL not found in Federation provider.", Fore.RED)
            else:
                log("Federation provider ID not found in registration details.", Fore.RED)
        else:
            log("Registration ID not found in response.", Fore.RED)
    else:
        log("Failed to authenticate to Delinea Platform.", Fore.RED)
        exit(1)

except Exception as e:
    log(f"Error: {e}", Fore.RED)
