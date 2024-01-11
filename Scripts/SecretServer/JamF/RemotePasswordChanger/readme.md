# Jamf Remote Password changer

The steps below show how to Set up and configure a Jamf Remote Password Changer, and Delinea Secret Server. 

If you have not already done so, please follow the steps in the **Instructions.md Document** found [Here](../Instructions.md)

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Jamf Remote Password Changer)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Password Changing
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Jamf Remote Password Changer.ps1](./Jamf%20RPC.ps1)
    - Click Save
    - This completes the creation of the Remote Password Script

### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Jamf Heartbeat)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Heartbeat
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Jamf Heartbeat.ps1](./Jamf%20Heartbeat.ps1)
    - Click Save
    - This completes the creation of the Jamf Heartbeat Script

## Create Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Click on Create Password Changer
- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script
- Enter a Name (Example - Jamf Remote Password Changer )
- Click Save
 - Under the **Verify Password Changed Commands** section, Enter the following information:
   - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Creted in the [Heartbeat](#heartbeat-script)	Section  

  - **Script Args**: ```$tenant-url $username $password ```
  - Click	**Save**

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Creted in the [remote-password-changer-script](#remote-password-changer-script)	Section  

  - **Script Args**: ```$tenant-url $username $newpassword $[1]$clientId $[1]$clientSecret ```
  - Click	**Save**
- This completes the creation of the RemotePassword Changer

## Update Jamf User template

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the Jamf User Template created in the [Instructions.md Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC** Checked
  - **RPC Max Attempts** 12
  - **RPC Interval Hours** 8
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 4
  - **Password Type to use** Select **Jamf Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
  - **Domain** tenant-url
  - **Password** Password
  - **Username** Username
- Click Save
- This completes the Update Jamf User template section

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Select the Jamf Remote Password Changer or the Password Changer created in the [create-password-change](#create-password-changer) section
- Click **Configure Scan Template at the bottom of the page**
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the Jamf User template created in the [Instructions.md Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **tenant-url** -> Domain
  - **Username** -> username
  - **Password** -> password
  - Leave all other fields blank
- Click Save
- This completes the Update Remote Password Changer section


> [!WARNING]
> When creating secrets with the Jamf User Account template, you must assign the appropriate privileged account secret to the Associated Secrets in position 1 (i.e. Jamf Client Credentials secret from [Create Secret in Secret Server for the Jamf Client Credentials Account](../Instructions.md/#create-secret-in-secret-server-for-the-jamf-client-credentials-account)). More information can be found [here](https://docs.delinea.com/online-help/secret-server/remote-password-changing/privileged-accounts-and-reset-secrets/index.htm#PrivilegedAccountsandResetSecrets).

