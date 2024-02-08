# PAN-OS Remote Password changer

The steps below show how to Set up and configure a PAN-OS Remote Password Changer.

If you have not already done, so, please follow the steps in the **Instructions.md Document** found [Here](../Instructions.md)

## Disclaimer
** Heartbeat will work with any account that in the Administrator Accounts section of the PAN-OS dashboard (Device -> Administrator). It will not work for accounts that only exist in the Local User Database.  If the account exits in both sections of the PAN-OS dashboard the Heartbeat will function correctly. Remote Password change will not work with any account in the Local User Database section of the PAN-OS dashboard.  These accounts are unable to update their password once they are associated with a Authentication Profile.**

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
- **Name**: ( example PAN-OS Remote Password Changer)
- **Description**: (Enter something meaningful to your Organization)
- **Active** (Checked)
- **Script Type**: Powershell
- **Category**: Password Changing
- **Merge Fields**: Leave Blank
- **Script**: Copy and paste the Script included in the file [PAN-OS RPC.ps1](./PAN-OS%20RPC.ps1)
- Click Save
- This completes the creation of the Remote Password Changing Script

### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example PAN-OS Heartbeat)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Heartbeat
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [PAN-OS Heartbeat.ps1](./PAN-OS%20Heartbeat.ps1)
    - Click Save
    - This completes the creation of the PAN-OS Heartbeat Script

## Create Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Click on Create Password Changer
- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script
- Enter a Name (Example - PAN-OS Remote Password Changer )
- Click Save
 - Under the **Verify Password Changed Commands** section, Enter the following information:
   - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Heartbeat](#heartbeat-script)	Section  
    - **Script Args:** 
      ```PowerShell
      	$tenant-url $username $password
      ```
  - Click	**Save**

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [remote-password-changer-script](#remote-password-changer-script)	Section  
  - **Script Args:**
    ```PowerShell
    $tenant-url $[1]$username $[1]$password $username $newpassword
    ```
- Click	**Save**
- This completes the creation of the Remote Password Changer

## Update PAN-OS User template

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the PAN-OS User Template created in the [Instructions.md Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC** Checked
  - **RPC Max Attempts** 12
  - **RPC Interval Hours** 8
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 4
  - **Password Type to use** Select **PAN-OS Remote Password Changer** or the Password Changer created in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
  - **Domain** workspace-url
  - **Password** Password
  - **Username** Username
- Click Save
- This completes the Update PAN-OS User template section

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select **Configure Password Changers**
- Select the PAN-OS Remote Password Changer or the Password Changer created in the [create-password-changer](#create-password-changer) section
- Click **Configure Scan Template at the bottom of the page**
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the PAN-OS User template created in the [Instructions.md Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **tenant-url** -> Domain
  - **Username** -> username
  - **Password** -> password
  - Leave all other fields blank
- Click Save
- This completes the Update Remote Password Changer section




