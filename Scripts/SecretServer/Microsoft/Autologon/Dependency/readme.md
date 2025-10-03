# Introduction

This will push the password to an encrypted registry location for configuring AutoLogon of a credential. If an unencrypted credential is found it will be removed and repalced with the encrypted method. After updating the credential there is a configurable pause and the target comptuier will restart/

## Prerequisites

- Machines with Autologon preconfigured
- Powershell remoting enabled on these machines

## Configuration

1. Add [autologon-dependency.ps1](autologon-dependency.ps1) script to Secret Server:
   - **ADMIN** > **Scripts**
     
2. Configure Dependency Changer:
   - **ADMIN** > **Remote Password Changing** > **Configure Dependency Changers** >
   - Click on Create New Dependency Changer
   - Type "PowerShell Script"
   - Select "Windows Autologon" from the previous tutorial
   - Name: Autologon Dependency
   - Check the box for "Create Template"
   - Click on the Scripts Tab:
      - Leave the box unchecked for "Use Advanced Scripts"
      - Select the Script from the previous steps
      - Arguments `$[1]$USERNAME $[1]$DOMAIN $[1]$PASSWORD $MACHINE $PASSWORD`
      - Save

## Notes

**Conditional Dependency Requirement:** The [autologon-dependency-validate.ps1](autologon-dependency-validate.ps1) script is not required in most cases. Certain Windows configurations may prevent autologon settings from taking effect unless this additional dependency is implemented.

**Windows Configuration Behavior:** Some Windows systems enforce a security requirement where updating the autologon registry key alone is insufficient. These configurations require the new password to be validated through an initial login attempt before the autologon settings become active. The validation script addresses this requirement by performing the necessary password validation step. The underlying cause of this configuration-specific behavior has not been fully investigated.

**Implementation Considerations:** If autologon configuration changes are not taking effect after updating the registry keys, implement the following steps:

### Autologin Validate Configuration (Optional, only implement if required by OS)

1. Disable the automatic restart option in the primary dependency

1. Add [autologon-validate.ps1](autologon-validate.ps1) script to Secret Server:
   - **ADMIN** > **Scripts**

1. Configure Dependency Changer:
   - **ADMIN** > **Remote Password Changing** > **Configure Dependency Changers** >
   - Click on Create New Dependency Changer
   - Type "PowerShell Script"
   - Select "Windows Autologon" from the previous tutorial
   - Name: Autologon Dependency Verify
   - Check the box for "Create Template"
   - Click on the Scripts Tab:
      - Leave the box unchecked for "Use Advanced Scripts"
      - Select the Script from the previous steps
      - Arguments `$[1]$USERNAME $[1]$DOMAIN $[1]$PASSWORD $MACHINE $USERNAME $PASSWORD $DOMAIN`
      - Save

1. Add the [windows-restart-dependency](../../Server%20Restart/Dependency) after the validation dependency to complete the configuration process
