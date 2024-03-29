# Entra ID Remote Password Changer
  
If you have not already done so, please click[here](../Instructions.md) to perform the basic configuration for interacting with Entra ID.

## Create the Azure AD / Entra ID Remote Password Changer Script in Secret Server

- Log in to the Delinea Secret Server

- Navigate to Admin / Scripts

- Click on Create Script

- Enter the Following Field Values:

  - **Name:** Provide a name for the script (for example Azure AD / Entra ID Remote Password Changer)

  - **Description:** Provide a description for the script (for example Azure AD / Entra ID Remote Password Changer)

  - **Active:** Checked

  - **Script Type:** PowerShell

  - **Category:** Password Changing

  - **Script:** Copy the contents of the [Entra ID RPC file](../Remote%20Password%20Changer/EbtraID%20RPC.ps1) script into the script field

- Click on Save

## Create the Azure AD / Entra ID Heartbeat Script in Secret Server

- Log in to the Delinea Secret Server

- Navigate to Admin / Scripts

- Click on Create Script

  - **Name:** Provide a name for the script (for example Azure AD / Entra ID Remote Password Changer)

  - **Description:** Provide a description for the script (for example Azure AD / Entra ID Remote Password Changer)

  - Select Active

  - **Script Type:** PowerShell

  - **Category:** Heartbeat

  - **Script:** Copy the contents of the [Entra ID Heartbeat file](./Entra%20ID%20Heartbeat.ps1) script into the script field

- Click on Save

  
  

## Creation of the Azure AD / Entra ID Remote Password Changer

- Log in to the Delinea Secret Server

- Navigate to Admin / Remote Password Changing

- Click on: Options

- Click on Configure Password Changers

- Click on Create Password Changer
- Enter the following field values:

  - **Base Password Changer:** PowerShell Script

  - **Name:** Provide a name for the password changer (for example Azure AD / Entra ID Remote Password Changer)

- Click on Save

- You will be redirected to the password changer configuration page

- In the Verify Password changed Commands section, provide the following:

  - **PowerShell Script:** Select the script you created in the previous step [Azure AD / Entra ID Heartbeat](#create-the-azure-ad--entra-id-heartbeat-script-in-secret-server)

  - **Script Args:**

  ```powershell

  $[1]$TenantID $[1]$application-id $[1]$ClientSecret  $username  $password

  ```
- Click Save

- In the Password Change Commands section provide the following:

  - **PowerShell Script:** Select the script you created in the previous step [Azure AD / Entra ID Remote Password Changer]

  - **Script Args:**

  ```powershell

  $[1]$Tenant-ID $[1]$application-id $[1]$Client-Secret $username  $newpassword

  ```
- Click on Save

- Click on **Configure Scan Template** and then **Edit**

- Click on the **Scan Template to use** dropdown and select the Entra ID Account Scan Template

- Map the following fields:

  - **Domain:** Domain

  - **Username:** Username

  - **Password:** Password

  - Click Save

## Associate the Azure AD / Entra ID Remote Password Changer with the Entra ID Account Template

- Log in to the Delinea Secret Server

- Navigate to Admin / Secret Templates

- Click on the Azure AD Account template

- Click on Mapping

- Click on Edit

- Change the following field to use the password changer you created in the previous step:

  - **Password Type to use:** Select the password changer you created in the previous step

- Map the following fields:

  - **Domain:** Domain

  - **Username:** Username

  - **Password:** Password
- Click on Save
  

## Associate scripting account to Azure AD secret

To be able to correctly use the password changer, the scripting account must be associated with the Azure AD secret. This can be done by following the steps below:

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Locate your secret(s) based on the Azure AD Account template

- Click on the secret

- Click on Remote Password Changing

- Go the Associated Secrets section in the bottom of the page

- Click on Edit

- Click on Add Secret

- Search for the earlier created [secret](../Initialize.md#create-secret-in-secret-server-for-the-entraid-privileged-account) for the application registration and select that

- Click on Save

  

This can Also bee done using a Secret Policy assigned to the Parent Folder

  

## Testing the configuration

If all went well, you now should have:

- A secret template for the application registration

- An application registration in Azure AD / Entra ID

- A secret in Secret Server for the application registration

- The password changer script in Secret Server

- The password changer configured in Secret Server to use the script

- The password changer associated with the Azure AD Account template

- An Azure AD Account secret (not covered in this guide)

- The application registration secret associated with the Azure AD Account secret

  

To test the configuration, you can first start with performing a Heartbeat on the Azure AD Account secret. This can be done by following the steps below:

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Locate your secret(s) based on the Azure AD Account template

- Click on the secret

- Click on Heartbeat

After a few moments the heartbeat should complete successfully.

  

To test the configuration, you can now change the password of the Azure AD Account secret. This can be done by following the steps below:

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Locate your secret(s) based on the Azure AD Account template

- Click on the secret

- Click on Change Password Now

- Select Randomly Generated or Manual (and enter a password)

- Click on Change Password

  

If there are any issues, please check the following:

- Heartbeat or Remote Password changing logs in the Web UI of Secret Server

- SSDE.log on the Distributed Engine