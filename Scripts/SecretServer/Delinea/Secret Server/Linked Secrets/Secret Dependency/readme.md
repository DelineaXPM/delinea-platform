# Delinea Secret Server Linked Secrets Dependency Changer

## Overview

Multiple secrets can exist for a single username-password combination, each with distinct templates and authorizations. The Linked Secrets Dependency Changer solves the challenge of managing password changes across these linked accounts using a linked password strategy. When passwords are updated on the Primary Secret, the updated password is automatically propagated to all dependent secrets.

The Linked Secrets Dependency Changer is a PowerShell script that enables updating passwords for multiple linked secrets simultaneously in Delinea Secret Server. This script is designed to work as a dependency changer for Remote Password Changing (RPC) operations, supporting both Delinea Platform and direct Secret Server authentication.

The script provides two operational modes:
- **Standard** - Updates passwoerd field for multiple secrets in a single bulk operation 
- **Advanced** - Using extra parameters you can initiate a full password change on target secrets if they support RPC functions. Additonally you can toggle individual actions rather than bulk actions for older Secret Server versions or if there are issues preventing bulk operation.

## Prerequisites

**Environment:**
- PowerShell 3.0 or later
- Delinea Secret Server

**API User Permissions:**

The API user account (Application Account in Secret Server or Service User in Delinea Platform) requires the following role permissions:
- **Edit Secret**
- **View Secret**
- **View Advanced Secret Options**
- **Edit access** to all secrets to be managed

**Setup Requirements:**
- The Primary Secret must have a text field to store linked secret IDs (e.g., "Linked" field)
- Each target secret must grant edit permissions to the Application Account/Service User in the Sharing section
- The Primary Secret must be configured for Remote Password Changing with the Application Account as an associated secret

## Installation

### Step 1: Upload Script to Scripts Library

1. Upload the script to the Scripts Library in Secret Server
2. Configure the following settings:
   - **State:** Enabled
   - **Script Type:** PowerShell
   - **Category:** Dependency
   - PowerShell Core processing is not required
3. Update the configuration variables at the top of the script:
   - Set either `$DelineaPlatformURL` or `$SecretServerURL` to your environment's URL
   - Leave the other URL as `$null` unless required as the configuration should be returned by the Vault Broker service

### Step 2: Create an Application Account

Create a service account with the required permissions:
- **Secret Server:** Create an Application Account
- **Delinea Platform:** Create a Service User

Ensure the account has the permissions listed in the Prerequisites section above.

### Step 3: Configure the Primary Secret Template

The Primary Secret requires a field to store the linked secret IDs. Choose one option:

**Option A:** Create a new template (copy of current template with added field)
- Create a new secret template based on your current template
- Add a new text field named **Linked**

**Option B:** Modify the existing template
- Add a new text field named **Linked** to your current template

**Option C:** Use an existing field
- Use an existing text field such as Notes
- Remember the field name for use in the dependency arguments

### Step 4: Populate Linked Secret IDs

1. Edit the Primary Secret
2. Locate the field designated for linked secret IDs
3. Enter the secret IDs as a **comma-separated list with no spaces**
   - Correct: `15,16,2692`
   - Incorrect: `15, 16, 2692` (spaces will cause errors)

### Step 5: Configure Remote Password Changing

1. In the Primary Secret, navigate to the **Remote Password Changing** tab
2. In the **Associated Secrets** section, add the Application Account/Service User created in Step 2
3. Save the configuration

### Step 6: Add the Dependency

1. Navigate to the Primary Secret's **Dependencies** tab
2. Click to add a new dependency
3. Configure the dependency:
   - **Type:** Select the script from the **Run PowerShell Script** section
   - **Group:** Select an existing group or create a new one
   - **Name:** Use a descriptive name (e.g., "Linked Secrets Update")
   - **Run As:** Select a secret that has permissions to run PowerShell on the site
   - **Arguments:** `$PASSWORD $[1]$USERNAME $[1]$PASSWORD $<LinkedFieldName>`
     - Replace `<LinkedFieldName>` with the actual field name (e.g., `$LINKED`)

### Step 7: Grant Permissions on Target Secrets

For each target secret that will be updated:
1. Open the target secret
2. Navigate to the **Sharing** section
3. Grant **Edit** permission to the Application Account/Service User created in Step 2

## Configuration

### Script Configuration Variables

Edit the following variables at the top of the script to match your environment:

```powershell
$DelineaPlatformURL = "https://privotter-services.delinea.app/"  # Delinea Platform URL
$SecretServerURL = $null                                           # Secret Server URL (optional if using Delinea Platform)
$debug = $false                                                    # Enable/disable debug logging
```

**DelineaPlatformURL**: Your Delinea Platform URL. Set to `$null` to authenticate directly to Secret Server.

**SecretServerURL**: Your Secret Server URL. Leave as `$null` to auto-retrieve from Delinea Platform.

**debug**: Set to `$true` to enable detailed logging for troubleshooting.

## Important: Secret ID Format

When entering linked secret IDs in your template field, use a **comma-separated list with no spaces**:
- ✅ Correct: `15,16,2692`
- ❌ Incorrect: `15, 16, 2692` (spaces will cause errors)

## Arguments

The script accepts the following arguments in order:

| Position | Argument | Description | Example |
|----------|----------|-------------|---------|
| 0 | $PASSWORD | The new password to set on the linked secrets | MyNewP@ss123 |
| 1 | $USERNAME | API username/client ID for authentication | api-user |
| 2 | $PASSWORD | API password/client secret for authentication | api-password |
| 3 | $\<FieldName\> | Comma-separated list of secret IDs from the template field | $LINKED or $NOTES |
| 4 | SecretAction | (Optional) `UpdatePassword` or `RotatePassword` (default: UpdatePassword) | RotatePassword |
| 5 | UpdateMode | (Optional) `BulkAction` or `Legacy` (default: BulkAction) | Legacy |

**Field Name:** The third argument is the name of the template field containing the linked secret IDs. Common examples:
- `$LINKED` - If you created or added a field named "Linked"
- `$NOTES` - If you're using an existing Notes field
- Use the exact field name from your template, prefixed with `$`

**Standard Configuration (Secret Server Dependency Changer):**
```
$PASSWORD $[1]$USERNAME $[1]$PASSWORD $<LinkedFieldName>
```

**Advanced Configuration (with explicit modes):**
```
$PASSWORD $[1]$USERNAME $[1]$PASSWORD $<LinkedFieldName> [RotatePassword|UpdatePassword] [BulkAction|Legacy]
```

## Operational Modes

Operational modes are specified via the 5th and 6th arguments in the dependency configuration, allowing you to control behavior without modifying the script.

### BulkAction (Default, Recommended)

Updates all linked secrets with a single bulk API operation. Available in Secret Server 10.1 and later.

**Advantages:** Single API call, efficient for many secrets, better performance, includes progress tracking.

**Dependency Argument:** `$PASSWORD $[1]$USERNAME $[1]$PASSWORD $LINKED` (default behavior)

### Legacy

Updates each secret individually. Use only if BulkAction is unavailable or causes compatibility issues. Available in Secret Server 9.0 and later.

**Use Case:** Older Secret Server versions that don't support bulk operations.

**Dependency Argument:** `$PASSWORD $[1]$USERNAME $[1]$PASSWORD $LINKED "UpdatePassword" "Legacy"`

## Secret Actions

Secret actions are specified via the 4th argument in the dependency configuration.

**UpdatePassword** (Default) - Updates the password field directly without remote system changes. Use when password is changed externally or no remote system integration is needed.

**Dependency Argument:** `$PASSWORD $[1]$USERNAME $[1]$PASSWORD $LINKED` (default behavior)

**RotatePassword** - Initiates remote password change on the target system, then updates the secret. Use when the remote system supports password rotation.

**Dependency Argument:** `$PASSWORD $[1]$USERNAME $[1]$PASSWORD $LINKED "RotatePassword"`

## Authentication

The script supports two authentication methods. Set at least one in the configuration:

**Delinea Platform (Recommended):**
```powershell
$DelineaPlatformURL = "https://privotter-services.delinea.app/"
$SecretServerURL = $null  # Auto-retrieved from platform
```
Uses OAuth2 client credentials flow. The script authenticates to Delinea Platform, retrieves the Secret Server vault URL, and uses the token for API calls.

**Direct Secret Server:**
```powershell
$DelineaPlatformURL = $null
$SecretServerURL = "https://privotter-services.secretservercloud.com/"
```
Uses password grant type OAuth2 authentication directly to Secret Server. Set both to `$null` will cause an error.

## Logging

Debug logs are written to the first available path:
- `$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log`
- `c:\inetpub\wwwroot\secretserver\log`
- `c:\temp`
- `c:\windows\temp`

Log file: `LinkedSecretsDependencyChanger.log`

Each entry includes timestamp, activity, and JSON-formatted context data. To enable logging, set `$debug = $true`.

## Troubleshooting

**Authentication Failures**

| Error | Solution |
|-------|----------|
| `Failed to authenticate to Delinea Platform` | Verify API credentials, confirm Platform URL is correct and accessible, check firewall rules |
| `Delinea Platform URL and Secret Server URL are both blank` | Configure at least one authentication method in the script configuration |

**Bulk Operation Failures**

| Error | Solution |
|-------|----------|
| `Bulk operation failed` | Verify Secret Server version (10.1+), check all secret IDs are valid, review logs for specific errors |
| Timeout | Script waits up to (secret count × 5) seconds. For large batches, monitor operation progress in Secret Server or split into smaller operations |

**Individual Secret Failures (Legacy Mode)**

Partial failures collect all errors and report them at the end. Check Secret Server audit logs for permission issues on specific secrets.

**No Log File Created**

Verify `$debug = $true`, ensure write permissions to one of the log paths, create `c:\temp` if missing, check PowerShell execution policy.

## API Requirements

The script uses the following Secret Server API endpoints:

**Delinea Platform:**
- `POST /identity/api/oauth2/token/xpmplatform` - OAuth token generation
- `GET /vaultbroker/api/vaults` - Retrieve vault URLs

**Secret Server (Bulk):**
- `POST /api/v1/bulk-secret-operations/update-secret-fields` - Bulk password updates
- `POST /api/v1/bulk-secret-operations/change-password-remotely` - Bulk password rotation
- `GET /api/v1/bulk-operations/{id}/progress` - Check bulk operation progress

**Secret Server (Legacy):**
- `PUT /api/v1/secrets/{id}/fields/password` - Update individual password
- `POST /api/v1/secrets/{id}/change-password` - Remote password change
