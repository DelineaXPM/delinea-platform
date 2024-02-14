# Intune Connector Overview

This connector provides the following functions  

- Discovery of Intune User Accounts in a given tenant


# Pre-Requisites   
This connector uses the Delinea.PoSH.Helper module. Follow the [installation instructions](../../Helper/readme.md) to add this module to all Distributed Engines or Web Servers that will be executing the scripts for this connector. 



## Intune User Account Management
- User management utilizes EntraID for the following functions
  - Remote Password Changing Intune users
  - Heartbeats to verify that user credentials are still valid
- **Click [Here](https://github.com/DelineaXPM/delinea-platform/tree/main/Scripts/SecretServer/EntraId) for more information and instructions.**

<!-- To be updated later:
Follow the Steps below to complete the base setup for the Connector

# Prepare Oauth Authentication

## OAuth Client Credentials Flow in Intune 

This connector utilizes an OAuth 2.0 application in Intune using the Client Credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Intune  APIs.
More information can be found [here](https://learn.microsoft.com/en-us/graph/auth/?view=graph-rest-1.0). 
​
### Prerequisites

- Access to a Intune instance with administrative privileges.
- Basic understanding of OAuth 2.0 and Intune administration.

## Create an OAuth Application Registry

- Create an OAuth application registry using the following method:
  - Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and client secret that the client needs to access the restricted resources on the instance.
  - Grant Graph API Application Permissions with at least:
    - DeviceManagementConfiguration.Read.All
    - DeviceManagementRBAC.Read.All
    - Group.Read.All
    - Group.GroupMember.Read.All
  - And Delegated API Permissions
    - User.Read
    - User.Read.All

*** For more information and directions, click [here](https://learn.microsoft.com/en-us/graph/auth-v2-service?view=graph-rest-1.0&tabs=http).

- Document the following values as they will be needed in the upcoming sections
  - ClientID, ClientSecret, TenantId
-->
# Creating secret template for Intune Accounts 

### Intune User Account Template

The following steps are required to create the Secret Template for Intune Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Intune User Template.xml File](./Templates/Intune%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Intune Discovery Account Template

The following steps are required to create the Secret Template for Intune Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Intune Discovery Credentials Template.xml File](./Templates/Intune%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Intune Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Intune-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Intune Discovery Account)
    - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - TenantId 
    - ClientId
    - ClientSecret
    - AdminRoles
    - Service-Account-Group-Names
    - LocalDomain
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Intune Discovery Account

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) 


