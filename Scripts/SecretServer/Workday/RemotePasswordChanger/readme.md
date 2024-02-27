# Workday Remote Password changer

The steps below show how to set up and configure a Workday Remote Password Changer.

If you have not already done, so, please follow the steps in the **Instructions Document** found [here](../Instructions.md)

## Disclaimer
**Currently, Workday does not support remote password changing due to the fact that most users credentials are stored in a federated account. The scripts provided here are placeholders to enable the functionality within Discovery.**

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: (example Workday Remote Password Changer)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Password Changing
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Workday RPC](./Workday%20RPC.ps1)
- Click Save


### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name:** ( example Workday Heartbeat)
    - **Description:** (Enter something meaningful to your Organization)
    - **Active:** (Checked)
    - **Script Type:** Powershell
    - **Category:** Heartbeat
    - **Merge Fields:** Leave Blank
    - **Script:** Copy and paste the Script included in the file [Workday Heartbeat Placeholder](./Workday%20Heartbeat%20Placeholder.ps1)
- Click Save



## Create Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Remote Password Changing**
- Click on **Options** (Dropdown List) and select ***Configure Password Changers**
- Click on **Create Password Changer**
- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script
- Enter a **Name** (Example - Workday Remote Password Changer )
- Click Save

Under the **Verify Password Changed Commands** section, Enter the following information:
  - **PowerShell Script** (DropdownList) Select PowerShell Script that was Created in the [Heartbeat Script](#heartbeat-script) Section
  - **Script Args**: (**Leave Blank**)
- Click **Save**

  

Under the **Password Change Commands** Section, Enter the following information:

-  **PowerShell Script** (DropdownList) Select PowerShell Script or the Script that was created in the [Remote Password Changer Script](#remote-password-changer-script) Section

-  **Script Args**:

```powershell

$username $[1]$ClientId  $[1]$username $[1]$SOAP-Endpoint $[1]$token-url  $newpassword $[1]$pk

```

- Click **Save**
  
## Update Workday Account Template

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Secret Templates**
- Find and Select the Workday User Template created in the [Instructions Document](../Instructions.md)
- Select the **Mapping** Tab 
- In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC:** Checked
  - **RPC Max Attempts:** 12
  - **RPC Interval Hours:** 8
  - **Enable Heartbeat:** Checked
  - **Heartbeat Interval Hours:** 4
  - **Password Type to Use:** Select **Workday Remote Password Changer** or the Password Changer created in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
  - **Domain:** tenant-url
  - **Password:** Password
  - **Username:** Username
- Click Save

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Admin** > **Remote Password Changing**
- Click on Options (Dropdown List) and select **Configure Password Changers**
- Select the Workday Remote Password Changer or the Password Changer created in the [Create Password Changer Section](#create-password-changer)
- Click **Configure Scan Template** at the bottom of the page
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the Workday User template created in the [Instructions Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **Username:** username
  - **Password:** password
  - Leave all other fields blank
- Click Save





