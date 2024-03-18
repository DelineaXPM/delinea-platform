# Github Remote Password changer

  

The steps below show how to Set up and configure a Github Remote Password Changer PlaceHolder

## Disclaimer

**Currently, Github does not support remote password changing for user accounts. The scripts provided here are placeholders to enable the functionality within and for Discovery.**

  

## Create Scripts

  

### Remote Password Changer Script


### Heartbeat Script

- Log in to Secret Server Tenant

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields

    - **Name:** ( example: Github Heartbeat)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Heartbeat

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [Github Heartbeat Placeholder Placeholder](./Github%20Heartbeat%20Placeholder.ps1)

- Click Save


  

### Remote Password Changer Script

- Log in to Secret Server Tenant

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields

    - **Name:** ( example: Github Remote Password Changer)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Password Changer

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [Github RPC Placeholder](./Github%20RPC%20Placeholder.ps1)

- Click Save



  

## Create Password Changer

  

- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **Admin** > **Remote Password Changing**

- Click on Options (Dropdown List) and select ***Configure Password Changers**

- Click on Create Password Changer

- Click on **Base Password Changer** (Dropdown List) and Select PowerShell Script

- Enter a Name (example: Github Remote Password Changer Placeholder )

- Click Save

- Under the **Verify Password Changed Commands** section, Enter the following information:

    - **PowerShell Script:** (Dropdown List) Select PowerShell Script or the Script that was Created in the [Heartbeat](#heartbeat-script) Section

    - **Script Args:** (Leave Blank)

- Click **Save**

- Under the **Password Change Commands** Section, Enter the following information:

    - **PowerShell Script:** (Dropdown List) Select PowerShell Script or the Script that was Created in the [Remote Password Changer Script](#remote-password-changer-script) Section

    - **Script Args:** (Leave Blank)

- Click **Save**

  

## Update Github User template

  

- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **Admin** > **Secret Templates**

- Find and Select the Github User Account Template created in the [Instructions.md Document](../instructions.md#github-user-account-template)

- Select the **Mapping** Tab

- In the **Password Changing** section, click edit and fill out the following

-  **Enable RPC** Checked

-  **RPC Max Attempts** 12

-  **RPC Interval Hours** 8

-  **Enable Heartbeat** Checked

-  **Heartbeat Interval Hours** 4

-  **Password Type to use** Select **Github Remote Password Changer Placeholder** or the Password Changer created in the [Create Password Changer Section](#create-password-changer)

- In the **Password Type Fields** Section, fill out the following:

    - **Domain:** Organization

    - **Password:** Password

    - **Username:** Username

- Click Save


## Update Remote Password Changer

- Log in to Secret Server Tenant (if not alreday logged in)

- Navigate to **ADMIN** > **Remote Password Changing**

- Click on Options (Dropdown List) and select **Configure Password Changers**

- Select the Slack Remote Password Changer or the Password Changer created in the [create-password-changer](#create-password-changer) section

- Click **Configure Scan Template at the bottom of the page**

- Click Edit

- Click the **Scan Template to use** (Dropdown List) Select the Github User Account template created in the [Discovery/readme.md Document](../Discovery/readme.md#create-github-account-scan-template)

- Map the following fields that appear after the selection

    - **workspace-url:** -> Domain

    - **Username:** -> username

    - **Password:** -> password

    - Leave all other fields blank

- Click Save

