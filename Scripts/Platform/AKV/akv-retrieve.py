import subprocess
import logging
from colorama import Fore, Style
from akv_config import KEY_VAULT_NAME, AZURE_TENANT_ID

def log(message, color=Fore.WHITE):
    """Log messages with color."""
    print(color + message + Style.RESET_ALL)

def run_command(command, error_message):
    """Run a shell command and handle errors."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        log(f"{error_message}: {result.stderr}", Fore.RED)
        raise Exception(error_message)
    return result.stdout.strip()

def obfuscate_secret(secret):
    """Obfuscate a secret to show only the first and last 4 characters."""
    if len(secret) <= 8:
        return secret
    return f"{secret[:4]}{'*' * (len(secret) - 8)}{secret[-4:]}"

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

try:
    # Section: Authenticate to Azure
    log("\n=== Authenticating to Azure ===", Fore.CYAN)
    try:
        run_command(f"az login --tenant {AZURE_TENANT_ID} --allow-no-subscriptions", "Failed to authenticate to Azure.")
        log("Successfully authenticated to Azure.", Fore.GREEN)
    except Exception as e:
        log(f"Failed to authenticate to Azure: {e}", Fore.RED)
        exit(1)

    # Section: Retrieve secrets from Azure Key Vault
    platform_client_id = run_command(f"az keyvault secret show --vault-name {KEY_VAULT_NAME} --name PLATFORM-CLIENT-ID --query value -o tsv", "Failed to retrieve PLATFORM_CLIENT_ID")
    platform_client_secret = run_command(f"az keyvault secret show --vault-name {KEY_VAULT_NAME} --name PLATFORM-CLIENT-SECRET --query value -o tsv", "Failed to retrieve PLATFORM_CLIENT_SECRET")

    # Obfuscate the retrieved secrets
    obfuscated_client_id = obfuscate_secret(platform_client_id)
    obfuscated_client_secret = obfuscate_secret(platform_client_secret)

    # Print the obfuscated secrets
    log(f"PLATFORM_CLIENT_ID: {obfuscated_client_id}", Fore.GREEN)
    log(f"PLATFORM_CLIENT_SECRET: {obfuscated_client_secret}", Fore.GREEN)

except Exception as e:
    log(f"An error occurred: {e}", Fore.RED)
