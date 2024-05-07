# Introduction

This document provides the details for configuring a dependency changer to synchronize randomized passwords from SecretServer to Rapid7.

## Prerequisites

- Running Rapid7 InsightVM instance
- Extracted [SS_Rapid7_Integration](replace_ss_rapid7_integration_package_url) package on the machine where Distributed Engine is installed. (Delinea.SS.InsightVM.exe and appsettings.json).
- Install latest .Net Runtime on DE machine [Click Here](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-8.0.0-windows-x64-installer).

# Setup in SecretServer
1.	Create new folder to store Rapid7 secrets
2.	Create secret for Rapid7 user in SecretServer under the same folder and store Rapid7 API user credentials and Rapid7 URL in to that secret (Secret Template will be Web Password)
3.	Make sure Remote Password Changer is enabled and configured into the Secret Server
4.  Following the creation of the shared credential in InsightVM the corresponding secret needs to be created in Secret Server under the same folder which we have created in 1st step.

# Setup SS_Rapid7_Integration
1.	Extract downloaded SS_Rapid7_Integration package on the machine where Distributed Engine is installed. (Delinea.SS.InsightVM.exe and appsettings.json)
2.	Open appsetting.json file and change the following flag values if required.

    a.	SkipSSLVerification flag – By default, a valid SSL certificate is required on the Rapid7 and Secret Server sides. We can bypass this verification by setting the flag value to True, but it poses a security risk.
    
    b.	IsLoggingEnabled flag -  By default, logging is enabled and it stores logs into the text file at the location where the Delinea.SS.InsightVM.exe is placed on the DE machine. We can disable logging by setting this flag's value to false.

- **Note**: When executing SS_Rapid7 integration through secret dependency changer, no need to enter secret server details into the appSettings.json file like SS_BaseUrl, SS_Domain, SS_FolderPath, InsightVM_API_User_SecretId.


# Create Script

1. Navigate to **Admin | Scripts**
2. Enter name: **Rapid7 Dependency**
3. Description: **Script for updating Rapid7 shared credential password**
4. Category: **Dependency**
5. Script: **Copy and Paste** the script [rapid7-update-password-dependency.ps1](rapid7-update-password-dependency.ps1)
6. Click **OK**

# Create Dependency

1. Navigate to your desired secret
2. Navigate to **RPC** tab
3. Under the **RPC** tab configure RPC and add privileged account secret as a 1st order as well as Rapid7 API user secret (created into the 2nd step of Setup in Secret Server) as a 2nd order into the Associated Secrets
4. Navigate to **Dependencies** tab
5. Create a **New Dependency** (_create a dependency group if one does not currently exist_)
6. Click the drop-down for **Type**
7. Select the **Rapid7 Dependency** under the **Run PowerShell Script** section
8. Provide a **Dependency Name**
9. Select privileged account secret into the **Run as** field
10. Enter **2** for **Wait(s)**
11. Arguments paste the following: `$NOTES $PASSWORD $[2]$USERNAME $[2]$PASSWORD $[2]$URL`
12. Click **Save**
13. Under the **Overview** tab, enter the Rapid7 credential id into the Notes field

> **Note**: The `$PASSWORD` is the field that contains new password.

> **Note**: The `$[2]$USERNAME` `$[2]$PASSWORD` `$[2]$URL`  are the fields that contains Rapid7 API user credentials and base URL to access Rapid7 API's.

You should now be able to rotate the password of the Rapid7 secret. After the waiting period, the dependency changer will update the password of Rapid7 shared credential on Rapid7 instance.
