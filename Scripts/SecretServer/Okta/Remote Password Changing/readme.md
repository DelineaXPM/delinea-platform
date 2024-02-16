# Okta Remote Password changer

The steps below show how to Setup and configure an Okta Remote Password Changer in Delinea Secret Server server. 

If you have not already done so, please follow the steps in the **instructions Document** found [here](../instructions.md)

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Okta Remote Password Changer)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Password Changing
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Okta Remote Password Changer](./Okta%20Remote%20Password%20Changer.ps1)
  - Click Save
  
### Heartbeat Script

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
  - **Name**: ( example Okta Heartbeat)
  - **Description**: (Enter something meaningful to your Organization)
  - **Active** (Checked)
  - **Script Type**: Powershell
  - **Category**: Heartbeat
  - **Merge Fields**: Leave Blank
  - **Script**: Copy and paste the Script included in the file [Okta Heartbeat](./Okta%20Heartbeat.ps1)
- Click Save

## Create Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Click on **Create Password Changer**
- Click on ***Base Password Changer* (Dropdown List) and Select PowerShell Script
- Enter a **Name** (Example - Okta Remote Password Changer )
- Click Save

- Under the **Verify Password Changed Commands** section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Create Heartbeat Script](#heartbeat-script)	Section  
  - **Script Args**: 
  ```PowerShell
  $[1]$tenant-url $username $newpassword 
  ```
- Click	*Save

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Remote Password Changer Script](#remote-password-changer-script)	Section  
  - **Script Args**:
  ```PowerShell
   $[1]tenant-url $[1]$client-id $[1]$Key-id $[1]$ $[1]Private-Key $username $newpassword 
  ```
- Click	Save


## Update Okta User template

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the Okta User Template created in the [Instructions Document](../instructions.md#okta-user-account-template)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following:
  - **Enable RPC** Checked
  - **RPC Max Attempts** 12
  - **RPC Interval Hours** 8
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 4
  - **Password Type to use** Select **Okta Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
  - **Domain** tenant-url
  - **Password** Password
  - **Username** Username
- Click Save

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Remote Password Changing**
- Click on **Options** (Dropdown List) and select ***Configure Password Changers**
- Select the Okta Remote Password Changer or the Password Changer created in the [Create Password Changer](#create-password-changer) section
- Click **Configure Scan Template** at the bottom of the page
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the Okta Account Scan Template created in the [Discovery readme Document](../Discovery/readme.md)
- Map the following fields that appear after the selection
  - **tenant-url:** Domain
  - **Username*:* username
  - **Password:** password
  - Leave all other fields blank
- Click Save






