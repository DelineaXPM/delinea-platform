# Asana Remote Password changer

The steps below show how to set up and configure a Asana Remote Password Changer, and Delinea Secret Server. 

If you have not already done so, please follow the steps in the **Instructions Document** found [Here](../Instructions.md)

## Disclaimer
> [!WARNING]
> **Currently, Asana does not support remote password changing or heartbeating for user accounts. The scripts provided here are placeholders to enable the functionality for Discovery.**


## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Asana Remote Password Changer)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Password Changing
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Asana Remote Password Changer](./Asana%20RPC%20Placeholder.ps1)
    - Click Save
- This completes the creation of the Remote Password Script

### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Asana Heartbeat)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Heartbeat
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Asana Heartbeat](./Asana%20Heartbeat%20Placeholder.ps1)
    - Click Save
- This completes the creation of the Asana Heartbeat Script

## Create Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Click on Create Password Changer
- Click on **Base Password Changer** (Dropdown List) and select PowerShell Script
- Enter a Name (Example - Asana Remote Password Changer )
- Click Save
 - Under the **Verify Password Changed Commands** section, Enter the following information:
   - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Heartbeat](#heartbeat-script)	Section  

  - **Script Args**: ``` ```
  - Click	**Save**

- Under the **Password Change Commands** section, enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was created in the [remote-password-changer-script](#remote-password-changer-script)	Section  
 
  - **Script Args**: ``` ```
  - Click	**Save**
- This completes the creation of the RemotePassword Changer

## Update Asana User template

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the Asana User Template created in the [Instructions Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
  - **Enable RPC** Checked
  - **RPC Max Attempts** 12
  - **RPC Interval Hours** 8
  - **Enable Heartbeat** Checked
  - **Heartbeat Interval Hours** 4
  - **Password Type to use** Select **Asana Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
  - **Domain** tenant-url
  - **Password** Password
  - **Username** Username
- Click Save
- This completes the Update Asana User template section

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not already logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select **Configure Password Changers**
- Select the Asana Remote Password Changer or the Password Changer created in the [create-password-change](#create-password-changer) section
- Click **Configure Scan Template** at the bottom of the page
- Click Edit
- Click the **Scan Template to Use** (Dropdown List) Select the Asana User template created in the [Instructions Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **tenant-url** -> Domain
  - **Username** -> username
  - **Password** -> password
  - Leave all other fields blank
- Click Save
- This completes the Update Remote Password Changer section