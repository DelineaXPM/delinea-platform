# Custom Azure AD / Entra ID base configuration

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Remote Password Changing EntraID/Azure/Office365  users

- Heartbeats to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for this integration. These steps are required to run any o fthe processes.

  

## Creating Secret Template for ServiceNow Accounts

  

### EntraId User Account Template

  

The provided functions leverage the Microsoft Graph functionality in Azure AD / EntraID. The script is designed to take input in the form of the following components:

  

- Tenant ID

- Application ID (which originates from an App Registration in Azure AD / EntraID)

- Client Secret (which again originates from an App Registration in Azure AD / EntraID)

  

## Requirements

  

- Valid Azure AD subscription with Azure AD / EntraID

- Dedicated App Registration to be used by the password changer.

- See [this](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) for more information on how to create an App Registration.

- Detailed steps details provided [below](#creating-an-app-registration).

- Custom template to store application registration information in Delinea Secret Server

- Detailed steps provided [below](#creating-secret-template-for-application-registration).

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

- This completes the creation of the User Account template

  

## Creating Secret Template for Privileged Account

  

The following steps are required to create the secret template for the application registration:

- Log in to the Delinea Secret Server

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Copy and Paste the XML in the [EntraID Privileged Account File](./Templates/EntraID%20Privileged%20Account.xml)

- Click on Save

- This completes the creation of the secret template

  

## Creating an App Registration

  

The application registration is used to provide the password changer with the necessary permissions to perform the password change. The following steps are required to create the application registration:

- Log in to the Azure / EntraID Portal

- Navigate to Azure Active Directory

- Navigate to App Registrations

- Click on New Registration

- Provide a name for the application registration

- Select the appropriate account type (single tenant or multi-tenant)

- Optionally provide a redirect URI

- Click on Register

- Navigate to Certificates & Secrets

- Click on New Client Secret

- Provide a description for the client secret

- Select an expiration date

- Click on Add

- Copy the client secret value and store it in Secret Server using the template created in the previous step

- Navigate to API Permissions

- Click on Add a permission

- Select Microsoft Graph

- Select Delegated permissions

- Select the following permissions:

- Directory.AccessAsUser.All (required to interact with Graph API on behalf of the user)

- User.Read

- For the Directory.AccessAsUser.All permission, click on the Grant admin consent for the respective tenant button

- This completes the creation of the application registration

  

## Providing Password Changer Application with Permissions to Manage Users

- Log in to the Azure / Entra ID Portal

- Navigate to Azure Active Directory / Entra ID

- Navigate to Roles and administrators

- Click on Add a role assignment

- Select the appropriate role (e.g. Global Administrator)

- Note: The role selected must have the ability to manage users

- The Password Administrator role is likely insufficient due to the fact that it does not have the ability to change passwords on Administrative Users.

- To change the password of a global administrator, the global administrator role must be selected.

- Search for and select the application registration created in the previous step

- Click on Add

- This completes the permission assignment of the application registration

  

## Create Secret in Secret Server for the EntraID Privileged Account

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Creating Secret Template for Privileged Account](#creating-secret-template-for-privileged-account) (in the example Entra ID Application Identity)

- Fill out the required fields with the information from the application registration

  - **Secret Name:** (for example Delinea Password Changer)

  - **Tenant ID:** (which can be retrieved from the Azure AD / Entra ID properties)

  - **Application ID:** (which can be retrieved from the Application Registration - Application (client) ID)

  - Client Secret which was generated in the [earlier step](#creating-an-app-registration)

- Click on Create Secret

  

## Installation of the Microsoft Graph PowerShell SDK on Distributed Engine

- Log in to the Delinea Distributed Engine

- Open a PowerShell prompt

- Run the following command to install the Microsoft Graph PowerShell SDK:

```powershell

install-module  -name Microsoft.Graph -scope allusers

```

- This completes the installation of the Microsoft Graph PowerShell SDK