# ThousandEyes Connector Base Configuration

This connector provides the following functions

- Discovery of ThousandEyes User Accounts in a given tenant

## Not currently available in ThousandEyes Cloud

- Remote Password Changing ThousandEyes users
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

# Pre-Requisites   
This connector uses the Delinea.PoSH.Helper module. Follow the [installation instructions](../../Helper/readme.md) to add this module to all Distributed Engines or Web Servers that will be executing the scripts for this connector. 

# Prepare Oauth Authentication

## OAuth Client Credentials Flow in ThousandEyes

This connector utilizes an OAuth Bearer token grant type. The OAuth Bearer Token will impersonate the scope and permissions of the assigned user on behalf of the application for what it needs to authenticate and interact with ThousandEyes APIs.

More information can be found [here](https://docs.thousandeyes.com/product-documentation/getting-started/getting-started-with-the-thousandeyes-api).

### Prerequisites

- Access to a ThousandEyes instance with administrative privileges.
- Basic understanding of API Keys and ThousandEyes administration.

## Create an OAuth Application Registry

- Create a OAuth Bearer Token using the following method:
- Create and record the AccessToken using the user account with appropriate permissions that the client needs to access the restricted resources on the instance.

*** For more information and directions, click [here](https://docs.thousandeyes.com/product-documentation/user-management/rbac#profile-tab).
- Document the following values as they will be needed in the upcoming sections
    - OAuth Bearer Token value

# Creating Secret Template for ThousandEyes Accounts

### ThousandEyes User Account Template

The following steps are required to create the Secret Template for ThousandEyes Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ThousandEyes User Template.xml File](./Templates/ThousandEyes%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### ThousandEyes Discovery Credentials Template

The following steps are required to create the Secret Template for ThousandEyes Discovery Credentials:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ThousandEyes Discovery Account Template.xml File](./Templates/ThousandEyes%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the ThousandEyes Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#ThousandEyes-discovery-credentials-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example ThousandEyes Discovery Account)
    - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - AccessToken
    - AdminRoles
    - Service-Account-Roles
    - LocalDomain
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the ThousandEyes Discovery Account

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)