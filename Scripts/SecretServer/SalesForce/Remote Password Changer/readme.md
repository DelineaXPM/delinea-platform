# Salesforce Remote Password Changer

  

The steps below show how to Setup and configure a Salesforce Remote Password Changer in Delinea Secret Server server.

  

If you have not already done, so, please follow the steps in the **Instructions.md Document** found [Here](../Instructions.md)

  

## Create Scripts

  

### Remote Password Changer Script

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields

-  **Name**: ( example Salesforce Remote Password Changer)

-  **Description**: (Enter something meaningful to your Organization)

-  **Active** (Checked)

-  **Script Type**: Powershell

-  **Category**: Password Changing

-  **Merge Fields**: Leave Blank

-  **Script**: Copy and paste the Script included in the file [ServiceNow Remote Password Changer.ps1](./ServiceNow%20Remote%20Password%20Changer.ps1)

- Click Save

- This completes the creation of the Rempte Password Script

  

### Heartbeat Script

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields

-  **Name**: ( example Salesforce Heartbeat)

-  **Description**: (Enter something meaningful to your Organization)

-  **Active** (Checked)

-  **Script Type**: Powershell

-  **Category**: Heartbeat

-  **Merge Fields**: Leave Blank

-  **Script**: Copy and paste the Script included in the file [ServiceNow Heartbeat.ps1](./ServiceNow%20Heartbeat.ps1)

- Click Save

- This completes the creation of the ServiceNow Heartbeat Script

  

## Create Password Changer

  

- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **ADMIN** > **Remote Password Changing**

- Click on Options (Dropdown List) and select ***Configure Password Changers**

- Click on Create Password Changer

- Click on ***Base Password Changer* (Dropdown List) and Select PowerShell Script

- Enter a Name (Example - Salesforce Remote Password Changer )

- Click Save

- Under the **Verify Password Changed Commands** section, Enter the following information:

-  **PowerShell Script** (DropdownList) Select PowerShell Script or the Script that was Created in the [Heartbeat](#heartbeat-script) Section

-  **Script Args**: Leave Blank

- Click **Save**

  

- Under the **Password Change Commands** Section, Enter the following information:

-  **PowerShell Script** (DropdownList) Select PowerShell Script or the Script that was Creted in the [remote-password-changer-script](#remote-password-changer-script) Section

-  **Script Args**:

```powershell

$[1]$tenant-url $[1]$username $[1]$password $[1]$client-id $[1]$client-secret $username  $newpassword

```

- Click **Save**

- This completes the creation of the RemotePassword Changer

  

## Update Salesforce User template

  

- Log in to Secret Server Tenant (if not alreday logged in)

- Navigate to **ADMIN** > **Secret Templates**

- Find and Select the Salesforce User Template created in the [instructions.md Document](../Instructions.md)

- Select the **Mapping** Tab

- In the **Password Changing** section, click edit and fill out the following

-  **Enable RPC** Checked

-  **RPC Max Attempts** 12

-  **RPC Interval Hours** 8

-  **Enable Heartbeat** Checked

-  **Heartbeat Interval Hours** 4

-  **Password Type to use** Select **Salesforce Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)

- In the **Password Type Fields** Section, fill out the following

-  **Domain** tenant-url

-  **Password** Password

-  **Username** Username

- Click Save

- This completes the Update Salesforce User template section

  

## Update Remote Password Changer

  

- Log in to Secret Server Tenant (if not alreday logged in)

- Navigate to **ADMIN** > **Remote Password Changing**

- Click on Options Dropdown List) and select ***Configure Password Changers**

- Select the Salesforce Remote Password Changer or the Password Changer created in the [create-password-change](#create-password-changer) section

- Click **Configure Scan Template at the bottom of the page**

- Click Edit

- Click the **Scan Template to use** (Dropdown List) Select the Salesforce User template created in the [Dircovery/readme.md Document](../Discovery/readme.md)

- Map the following fields that appear after the selection

-  **tenant-url** -> Domain

- **Username -> username

-  **Password** -> password

- Leave all other fields blank

- Click Save

- This completes the Update Remote Password Changer section