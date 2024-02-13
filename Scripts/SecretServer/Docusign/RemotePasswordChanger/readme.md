# Docusign Remote Password changer

The steps below show how to set up and configure a Docusign Remote Password Changer, and Delinea Secret Server. 

If you have not already done so, please follow the steps in the **Instructions Document** found [here](../Instructions.md)

## Disclaimer
> [!WARNING]
> **Currently, Docusign does not support remote password changing for user accounts. The scripts provided here are placeholders to enable the functionality within and for Discovery.**


## Create Scripts

### Remote Password Changer Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Docusign Remote Password Changer)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Password Changing
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Docusign Remote Password Changer](./Docusign%20RPC%20Placeholder.ps1)
    - Click Save
- This completes the creation of the Remote Password Script

### Heartbeat Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields 
    - **Name**: ( example Docusign Heartbeat)
    - **Description**: (Enter something meaningful to your Organization)
    - **Active** (Checked)
    - **Script Type**: Powershell
    - **Category**: Heartbeat
    - **Merge Fields**: Leave Blank
    - **Script**: Copy and paste the Script included in the file [Docusign Heartbeat](./Docusign%20Heartbeat%20Placeholder.ps1)
    - Click Save
- This completes the creation of the Docusign Heartbeat Script

## Create Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select **Configure Password Changers**
- Click on Create Password Changer
- Click on ***Base Password Changer* (Dropdown List) and Select PowerShell Script
- Enter a Name (Example - Docusign Remote Password Changer )
- Click Save
 - Under the **Verify Password Changed Commands** section, Enter the following information:
   - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Heartbeat](#heartbeat-script)	Section  

  - **Script Args**: ``` ```
  - Click	**Save**

- Under the **Password Change Commands** Section, Enter the following information:
  - **PowerShell Script**  (DropdownList) Select PowerShell Script or the Script that was Created in the [Remote Password Changer Script](#remote-password-changer-script)	Section  
 
  - **Script Args**: ``` ```
  - Click	**Save**
- This completes the creation of the RemotePassword Changer

## Update Docusign User Template

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Secret Templates**
- Find and Select the Docusign User Template created in the [Instructions Document](../Instructions.md)
 - Select the **Mapping** Tab 
 - In the **Password Changing** section, click edit and fill out the following
    - **Enable RPC** Checked
    - **RPC Max Attempts** 12
    - **RPC Interval Hours** 8
    - **Enable Heartbeat** Checked
    - **Heartbeat Interval Hours** 4
    - **Password Type to use** Select **Docusign Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)
- In the **Password Type Fields** Section, fill out the following
    - **Domain** tenant-url
    - **Password** Password
    - **Username** Username
- Click Save
- This completes the Update Docusign User template section

## Update Remote Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)
- Navigate to **ADMIN** > **Remote Password Changing**
- Click on Options (Dropdown List) and select ***Configure Password Changers**
- Select the Docusign Remote Password Changer or the Password Changer created in the [Create Password Change](#create-password-changer) section
- Click **Configure Scan Template at the bottom of the page**
- Click Edit
- Click the **Scan Template to use** (Dropdown List) Select the Docusign User template created in the [Instructions Document](../Instructions.md)
- Map the following fields that appear after the selection
  - **tenant-url** -> Domain
  - **Username** -> username
  - **Password** -> password
  - Leave all other fields blank
- Click Save
- This completes the Update Remote Password Changer section