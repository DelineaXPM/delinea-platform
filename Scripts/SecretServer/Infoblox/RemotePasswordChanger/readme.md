# Infoblox Remote Password changer

The steps below show how to Set up and configure an Infoblox Remote Password Changer.

If you have not already done, so, please follow the steps in the **Instructions Document** found [here](../Instructions.md)

## Disclaimer
**Heartbeat will work with all LOCAL or SAML_LOCAL authentication types.  However it will only works with Accounts that have API access.  API access is enabled at a group level.  To enable API access, go to Administration -> Administrators -> Groups -> Click on Group -> Click on Pencil -> Roles -> Allowed Interfaces -> API**

**Remote Password Changing requires an Associated Account.  This Privileged account must have a Superuser Role** 

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name:** ( example Infoblox Remote Password Changer)
    - **Description:** (Enter something meaningful to your Organization)
    - **Active:** (Checked)
    - **Script Type:** Powershell
    - **Category:** Password Changing
    - **Merge Fields:** Leave Blank
    - **Script:** Copy and paste the Script included in the file [Infoblox-WAPI RPC](./Infoblox-WAPI%20RPC.ps1)
    - Click Save

### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name:** ( example Infoblox Heartbeat)
    - **Description:** (Enter something meaningful to your Organization)
    - **Active:** (Checked)
    - **Script Type:** Powershell
    - **Category:** Heartbeat
    - **Merge Fields:** Leave Blank
    - **Script:** Copy and paste the Script included in the file [Infoblox-WAPI Heartbeat API](./Infoblox-WAPI%20Heartbeat%20API.ps1)
    - Click Save
  

## Create Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Remote Password Changing**
- Click on **Options** (Dropdown List) and select **Configure Password Changers**
- Click on **Create Password Changer**
- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script
- Enter a Name (Example - Infoblox Remote Password Changer )
- Click Save
 - Under the **Verify Password Changed Commands** section, Enter the following information:
   - **PowerShell Script**  (DropdownList) Select Infoblox Heartbeat Script or the Script that was Created in the [Heartbeat](#heartbeat-script)	Section  
    - **Script Args:** 
      ```PowerShell
      $tenant-url $username $password
      ```
  - Click	**Save**

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select Infoblox Remote Password Changer Script or the Script that was Created in the [Remote Password Changer Script](#remote-password-changer-script)	Section  
  - **Script Args:**
    ```PowerShell
    $tenant-url $[1]$username $[1]$password  $username $newpassword
    ```
- Click	**Save**

## Update Infoblox User template

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the Infoblox User Template created in the [Instructions Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC** Checked
  - **RPC Max Attempts** 12
  - **RPC Interval Hours** 8
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 4
  - **Password Type to use** Select **Infoblox Remote Password Changer** or the Password Changer created in the [Create Password Changer Section](#create-password-changer)
  - In the **Password Type Fields** Section, fill out the following
    - **Domain** workspace-url
    - **Password** Password
    - **Username** Username
- Click Save

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select **Configure Password Changers**
- Select the Infoblox Remote Password Changer or the Password Changer created in the [Create Password Changer](#create-password-changer) section
- Click **Configure Scan Template at the bottom of the page**
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the Infoblox User template created in the [Instructions.md Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **tenant-url** -> Domain
  - **Username** -> username
  - **Password** -> password
  - Leave all other fields blank
- Click Save




