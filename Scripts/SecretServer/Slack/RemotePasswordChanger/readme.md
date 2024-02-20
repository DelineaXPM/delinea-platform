# Slack Remote Password changer

The steps below show how to Set up and configure a Slack Remote Password Changer.

If you have not already done, so, please follow the steps in the [Instructions Document](../Instructions.md)

## Disclaimer
**Currently, Slack does not support remote password changing for user accounts. The scripts provided here are placeholders to enable the functionality within and for Discovery.**

## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **Administration** -> **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name:** Example Slack Remote Password Changer
    - **Description:** Enter something meaningful to your Organization
    - **Active** Checked
    - **Script Type:** PowerShell
    - **Category:** Password Changing
    - **Merge Fields:** Leave Blank
    - **Script:** Copy and paste the Script included in the file [Slack RPC Placeholder](./Slack%20RPC%20Placeholder.ps1)
    - Click **Save**

### Heartbeat Script
- Navigate to **Administration** -> **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name:** Example Slack Heartbeat
    - **Description:** Enter something meaningful to your Organization
    - **Active** Checked
    - **Script Type:** PowerShell
    - **Category:** Heartbeat
    - **Merge Fields:** Leave blank
    - **Script:** Copy and paste the script included in the file [Slack Heartbeat Placeholder](./Slack%20Heartbeat%20Placeholder.ps1)
    - Click **Save**


## Create Password Changer
- Navigate to **Administration** -> **Configuration** -> **Remote Password Changing**
- Click on **Options** (Dropdown List) and select ***Configure Password Changers**
- Click on **Create Password Changer**
- Click on **Base Password Changer** (Dropdown List) and select **PowerShell Script**
- Enter a **Name:** *Example - Slack Remote Password Changer*
- Click **Save**
  - Under the **Verify Password Changed Commands** section, Enter the following information:
    - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was created in the [heartbeat](#heartbeat-script)	Section  
    - **Script Args:** 
            ```  ```
  - Click	**Save**

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was created in the [remote password changer script](#remote-password-changer-script) section  
  - **Script Args:** 
            ```  ```
- Click	**Save**

## Update Slack User template
- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Administration** -> **Secret Templates**
- Find and Select the Slack User Template created in the [Instructions.md Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC** Checked
  - **RPC Max Attempts** 1
  - **RPC Interval Hours** 1
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 128
  - **Password Type to use** Select **Slack Remote Password Changer** or the Password Changer created in the [create password changer](#create-password-changer) section
- In the **Password Type Fields** Section, fill out the following
  - **Domain:** workspace-url
  - **Password:** Password
  - **Username:** Username
- Click **Save**

## Update Remote Password Changer
- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **Administration** -> **Remote Password Changing**
- Click on **Options** (Dropdown List) and select **Configure Password Changers**
- Select the Slack Remote Password Changer or the password changer created in the [create password changer](#create-password-changer) section
- Click **Configure Scan Template at the bottom of the page**
- Click **Edit**
- Click the **Scan Template to use** (Dropdown List) Select the Slack User template created in the [Instructions document](../Instructions.md)
- Map the following fields that appear after the selection
  - **workspace-url:** Domain
  - **Username:** Username
  - **Password:** Password
  - Leave all other fields blank
- Click **Save**
