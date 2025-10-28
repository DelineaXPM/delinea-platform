# Delinea Secret Server Linked Secrets Dependency Changer

## Overview

The Linked Secrets Dependency Changer is a PowerShell script that enables updating passwords for multiple linked secrets simultaneously in Delinea Secret Server. This script is designed to work as a dependency changer for Remote Password Changing (RPC) operations, supporting both Delinea Platform and direct Secret Server authentication.

## Prerequisites

- PowerShell 3.0 or later
- Network connectivity to Delinea Platform or Secret Server
- Valid API credentials with appropriate permissions set as associated secret 1 on the primary secret
  - Delinea Platform Service User
    - Create a password template secret and store the client id and secret as the username and password
  - Secret Server Application User
    - Create a password template secret and store the username and password for the app user
- The script must be configured as a dependency changer in Secret Server

## Installation

1. Upload the the script to your Secret Server scripts
  - Script Type: Powershell
  - Category: Dependency
  - Use Powershell Core: no   
1. Add a new dependency to the Primary secret
  - Secret must have lined to a password changer and have RPC enabled
  - Secret should have a field to be used to store the IDs of linked secrets (Notes ca be used for this)
1. Configure the script arguments as described in the Arguments section

## Configuration

### Script Configuration Variables

Edit the following variables at the top of the script to match your environment:

```powershell
$DelineaPlatformURL = "https://privotter-services.delinea.app/"  # Delinea Platform URL (for cloud customers)
$SecretServerURL = $null                                           # Secret Server URL (optional if using Delinea Platform)
$debug = $false                                                    # Enable/disable debug logging
```

**DelineaPlatformURL**: Your Delinea Platform URL. Set to `$null` to authenticate directly to Secret Server.

**SecretServerURL**: Your Secret Server URL. Leave as `$null` to auto-retrieve from Delinea Platform.

**debug**: Set to `$true` to enable detailed logging for troubleshooting.

## Arguments

The script accepts the following arguments in order:

| Position | Argument | Description | Example |
|----------|----------|-------------|---------|
| 0 | $PASSWORD | The new password to set on the linked secrets | MyNewP@ss123 |
| 1 | $USERNAME | API username/client ID for authentication | api-user |
| 2 | $PASSWORD | API password/client secret for authentication | api-password |
| 3 | $<FIELD> | Template field that contains a comma-separated list of secret IDs to update | 123,456,789 |
| 4 | SecretAction | (Optional) `UpdatePassword` or `RotatePassword` (default: UpdatePassword) | UpdatePassword |
| 5 | UpdateMode | (Optional) `BulkAction` or `Legacy` (default: BulkAction) | BulkAction |

**Standard Configuration (Secret Server Dependency Changer):**
```
$PASSWORD $[1]$USERNAME $[1]$PASSWORD $<Field Name>
```

**Advanced Configuration (with explicit modes):**
```
$PASSWORD $[1]$USERNAME $[1]$PASSWORD $<Field Name> [RotatePassword|UpdatePassword] [BulkAction|Legacy]
```

## Operational Modes

### BulkAction (Default, Recommended)

Updates all linked secrets with a single bulk API operation. Available in Secret Server 10.1 and later.

**Advantages:** Single API call, efficient for many secrets, better performance, includes progress tracking.

### Legacy

Updates each secret individually. Use only if BulkAction is unavailable or causes compatibility issues.

## Secret Actions

**UpdatePassword** (Default) - Updates the password field directly without causing additional RPC events. Useful for keeping multiple copies of the same credential in sync

**RotatePassword** - Initiates remote password change on the target system, then updates the secret. Use when the remote system supports password rotation.

## Authentication

The script supports two authentication methods. Set at least one in the configuration:

**Delinea Platform (Recommended):**
```powershell
$DelineaPlatformURL = "https://privotter-services.delinea.app/"
$SecretServerURL = $null  # Auto-retrieved from platform
```
Uses OAuth2 client credentials flow. The script authenticates to Delinea Platform, retrieves the Secret Server vault URL, and uses the token for API calls. If there are issues getting the vault from the vaultbroker service. You can add the URL for the underlying Secret Server Vault linked to delinea.app

**Direct Secret Server:**
```powershell
$DelineaPlatformURL = $null
$SecretServerURL = "https://privotter-services.secretservercloud.com/"
```


## Logging

Debug logs are written to the first available path:
- `$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log`
- `c:\inetpub\wwwroot\secretserver\log`
- `c:\temp`
- `c:\windows\temp`

Log file name: `LinkedSecretsDependencyChanger.log`

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

## Supported Secret Server Versions

- **BulkAction Mode:** Secret Server 10.1 and later
- **Legacy Mode:** Secret Server 9.0 and later

## Security Considerations

- Log files contain operation details but not passwords
- Ensure the script runs with appropriate permissions
- Use HTTPS for all Secret Server and Delinea Platform connections
- Restrict access to the script and log files
- Regularly audit dependency changer operations
