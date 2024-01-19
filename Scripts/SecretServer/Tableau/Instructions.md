# Tableau Connector Overview

This connectore provides the following functions  

- Discovery of Tableau User Accounts in a given Site

## Not currently available in Tableau Cloud

- Remote Password Changing Tableau users
- Heartbeats to verify that user credentials are still valid
> [!NOTE]
> For Tableau Cloud, you can update the site role for a user, but **you _cannot update or change a user's password,_ user name (email address), or full name.**
> [Reference Documentation](https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_ref_users_and_groups.htm#update_user).

Follow the Steps below to complete the base setup for the Connector

## Prepare Oauth Authentication

## OAuth Client Credentials Flow in Tableau
<!--For development testing, a Personal Access Token is being used instead of the JWToken. -->
This connector utilizes an OAuth 2.0 application in Tableau using the JWT Bearer grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Tableau APIs.
More information can be found [here](https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_ref_authentication.htm). 
​
### Prerequisites

- Access to a Tableau instance with administrative privileges.
- Basic understanding of OAuth 2.0 and Tableau administration.

## Create an OAuth Application Registry
<!--For development testing, a Personal Access Token is being used and this method below was not tested -->
- Create an OAuth application registry using the following method:
  - Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and client secret that the client needs to access the restricted resources on the instance.

*** For more information click [here](https://help.tableau.com/current/online/en-us/connected_apps_eas.htm).

- Document the following values as they will be needed in the upcoming sections
  - clientId, clientSecret.

## Creating secret template for Tableau Accounts 

### Tableau User Account Template

The following steps are required to create the Secret Template for Tableau Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Tableau User Template.xml File](./Templates/Tableau%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Tableau Client Credentials Template

The following steps are required to create the Secret Template for Tableau Client Credentials:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Tableau Client Credentials Template.xml File](./Templates/Tableau%20Client%20Credentials.xml)
- Click on Save
- This completes the creation of the User Account template


## Create secret in Secret Server for the Tableau Client Credentials
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#tableau-client-credentials-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Tableau SiteName Client Credential)
    - tenant-url (Tableau base tenant url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - Clientid
    - clientsecret
    - admin-roles
    - service-account-group-names
    - content-url (This is your Site Name)
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Tableau Client Credentials

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) 


