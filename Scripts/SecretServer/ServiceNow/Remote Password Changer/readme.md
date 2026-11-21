# ServiceNow Remote Password Changer

## Native Support Notice

Secret Server now includes native out-of-the-box support for ServiceNow password changing and heartbeat functionality. For the built-in implementation, see the [official ServiceNow RPC Integration documentation](https://docs.delinea.com/online-help/integrations/servicenow/rpc-config/servicenow-rpc-integration.htm).

This custom implementation can be used when:
- You need additional customization not available in the native implementation
- You require specific configurations for your organization
- You are using an older version of Secret Server without native ServiceNow support

## Overview

The steps below show how to set up and configure a ServiceNow Remote Password Changer in Delinea Secret Server.

  

If you have not already done, so, please follow the steps in the **Instructions Document** found [here](../Instructions.md)

  

## Create Scripts

  

### Remote Password Changer Script

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields

    - **Name:** ( example: ServiceNow Remote Password Changer)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Password Changing

    - **Merge Fields:** Leave Blank

    - **Script**: Copy and paste the Script included in the file [ServiceNow Remote Password Changer](./ServiceNow%20Remote%20Password%20Changer.ps1)

- Click Save


### Heartbeat Script



- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields:

    - **Name:** ( example: ServiceNow Heartbeat)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Heartbeat

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [ServiceNow Heartbeat](./ServiceNow%20Heartbeat.ps1)

- Click Save


## Create Password Changer

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Remote Password Changing**

- Click on Options (dropdown List) and select **Configure Password Changers**

- Click on Create Password Changer

- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script

- Enter a Name (Example - ServiceNow Remote Password Changer )

- Click Save

- Under the **Verify Password Changed Commands** section, Enter the following information:

-  **PowerShell Script** (DropdownList) Select ServiceNow Heartbeat or the Script that was Created in the [Heartbeat](#heartbeat-script) Section

-  **Script Args**:
    ``` powershell
    $tenant-url $[1]$username $[1]$password $[1]$client-id $[1]$client-secret $username $password
    ```
- Click **Save**
  
- Under the **Password Change Commands** Section, Enter the following information:

-  **PowerShell Script** (DropdownList) Select ServiceNow Remote Password Changer or the Script that was Created in the [remote password changer script](#remote-password-changer-script) Section

-  **Script Args**: 

    ``` powershell
    $tenant-url $[1]$username $[1]$password $[1]$client-id $[1]$client-secret $username $newpassword
    ```

- Click **Save**

- This completes the creation of the RemotePassword Changer

  

## Update ServiceNow User template

  

- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **ADMIN** > **Secret Templates**

- Find and Select the ServiceNow User Template created in the [instructions.md Document](../Instructions.md)

- Select the **Mapping** Tab

- In the **Password Changing** section, click edit and fill out the following

-  **Enable RPC** Checked

-  **RPC Max Attempts** 12

-  **RPC Interval Hours** 8

-  **Enable Heartbeat** Checked

-  **Heartbeat Interval Hours** 4

-  **Password Type to use** Select **ServiceNow Remote Password Changer** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)

- In the **Password Type Fields** Section, fill out the following

-  **Domain** host

-  **Password** Password

-  **Username** Username

- Click Save


## Update Remote Password Changer
  
- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **Admin** > **Remote Password Changing**

- Click on Options (dropdown List) and select **Configure Password Changers**

- Select the ServiceNow Remote Password Changer or the Password Changer created in the [Create Password Changer](#create-password-changer) section

- Click **Configure Scan Template at the bottom of the page**

- Click Edit

- Click the **Scan Template to use** (Dropdown List) Select the ServiceNow User template created in the [Instructions Document](../Instructions.md)

- Map the following fields that appear after the selection

    - **host** -> Domain

    - **Username** -> username

    - **Password** -> password

- Leave all other fields blank

- Click Save

This completes the creation of the Remote Password Changer