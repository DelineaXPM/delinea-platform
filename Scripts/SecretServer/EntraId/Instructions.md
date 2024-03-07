# Custom Azure AD / Entra ID base configuration

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Remote Password Changing EntraID/Azure/Office365  users

- Heartbeats to verify that user credentials are still valid

  

Follow the steps below to complete the base setup for this integration. These steps are required to run any of the processes.

  

## Creating Secret Template for EntraID Accounts

  

### EntraId User Account Template

  

The provided functions leverage the Microsoft Graph functionality in Azure AD / EntraID. The script is designed to take input in the form of the following components:

  

- Tenant ID

- Application ID (which originates from an App Registration in Azure AD / EntraID)

- Client Secret (which again originates from an App Registration in Azure AD / EntraID)

  

## Requirements

  

- Valid Azure AD subscription with Azure AD / EntraID

- Dedicated App Registration to be used by the password changer

- See [here](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) for more information on creating an App Registration.

- Detailed steps are provided [below](#creating-an-app-registration).

- Custom template to store application registration information in Delinea Secret Server

- Detailed steps are provided [below](#creating-a-secret-template-for-the-application-registration).

- Installation of the [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/en-us/graph/powershell/installation) on the Delinea Distributed Engine

- Template to store AzureAD / EntraID secrets.

- The username should be stored in the UPN format (username@domain) for the script to function.

  

## Creating Secret Template for EntraID Accounts

  

### Creating Secret Template for User Accounts

  

The following steps are required to create the Secret Template for EntraID Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Entra ID User File](./Templates/Entra%20ID%20User.xml)

- Click on Save

  

## Creating a Secret Template for the Application Registration

  

The following steps are required to create the secret template for the Application Registration:

- Log in to the Delinea Secret Server

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Copy and Paste the XML in the [EntraID Application Registration File](./Templates/EntraID%20Application%20Registration.xml)

- Click on the Mappings Tab

- Click **Edit** 

- Select the **Enable RPC** Checkbox

- Click the **Password Type to use** Dropdown and Select the **Generic Discovery-Only Credentials** option

- Under the **Password Type Fields** Section, enter the following Values:

  - **User Name:** Application-Id

  - **Password:** Client-Secret
  
- Click on Save

**Note:** This is a Generic Password Changer that does not perform a Password Change, but is required to use the Secret that will be created in the Discovery Source later in this configuration

## Creating an App Registration

  

The application registration gives the password changer the necessary permissions to perform the password change. The following steps are required to create the application registration:

- Log in to the Azure / EntraID Portal

- Navigate to Azure Active Directory

- Navigate to App Registrations

- Click on New Registration

- Provide a name for the Application Registration

- Select the appropriate account type (single tenant or multi-tenant)

- Optionally provide a redirect URI

- Click on Register

- Navigate to Certificates & Secrets

- Click on New Client Secret

- Provide a description for the client secret

- Select an expiration date

- Click on Add

- Copy the client secret value and store it as it will be needed when creating the Application Registration Secret

- Navigate to API Permissions

- Click on Add a permission

- Select Microsoft Graph

- Select Delegated permissions

- Select the following permissions:

  - `Directory.AccessAsUser.All` (required to interact with Graph API on behalf of the user)

  - `User.Read`

- For the `Directory.AccessAsUser.All` permission, click on the Grant admin consent for the respective tenant button

  
## Providing Password Changer Application with Permissions to Manage Users

- Log in to the Azure / EntraID Portal

- Navigate to Azure Active Directory / Entra ID

- Navigate to Roles and administrators

- Click on Add a role assignment

- Select the appropriate role (e.g. Privileged Authentication Administrator)

   **Note:** The role selected must have the ability to manage users
    The Password Administrator role is likely insufficient because it cannot change passwords on Administrative Users.

- Search for and select the application registration created in the previous step

- Click on Add


## Create a Secret in Secret Server for the EntraID Application Registration

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Creating a Secret Template for Application Registration](#creating-a-secret-template-for-the-application-registration) 

- Fill out the required fields with the information from the application registration

  - **Secret Name:** (for example Delinea Password Changer)

  - **Tenant ID:** (which can be retrieved from the Azure AD / Entra ID properties)

  - **Application ID:** (which can be retrieved from the Application Registration - Application ID)

  - **Client Secret:** (This was generated in the [earlier step](#creating-an-app-registration))

  - **Admin-Roles:** (Comma-separated list of roles that are considered to be Administrative Roles)

  - **service-account-groups:**	(Comma separated list of groups considered to be Service Accounts)

- Click on Create Secret

  

## Installation of the Microsoft Graph PowerShell SDK on Distributed Engine

- Log in to the Delinea Distributed Engine

- Open a PowerShell prompt

- Run the following command to install the Microsoft Graph PowerShell SDK:

  ```powershell

  install-module  -name Microsoft.Graph -scope allusers

  ```

  This completes the basic configuration.  You may proceed to configure Discovery by clicking [here](./Discovery/readme.md) and/or Remote Password Changer [here](./Remote%20Password%20Changer/readme.md)
