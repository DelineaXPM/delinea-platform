# Jamf Connector Overview

This connector provides the following functions  

- Discovery of Jamf user accounts in a given Workspace
- Remote Password Changing Jamf users
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

## Prepare Oauth Authentication

## OAuth Client Credentials Flow in Jamf

This connector utilizes an OAuth 2.0 application in Jamf using the client credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Jamf APIs.
​
### Prerequisites

- Access to a Jamf instance with administrative privileges.
- Basic understanding of OAuth 2.0, Jamf Pro and Classic APIs, and Jamf administration.
- Jamf v10.25.0 or greater.

## Create an OAuth Application Registry
- Create an API Role and Client in Jamf Pro:
  - Create an API Role, API Client, and generate a Client Secret. This creates an OAuth source for authorization that the client needs to access the restricted resources on the instance. Reference KB can be found [here](https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/API_Roles_and_Clients.html). 
- Grant the created API role privileges for discovery and user management:
  - *Read Accounts*, *Update Accounts*

### For more information refer to the manufacturer documentation
  - [Client Credentials](https://developer.jamf.com/jamf-pro/docs/client-credentials)
  - [Pro API Privilege Requirements](https://developer.jamf.com/jamf-pro/docs/privileges-and-deprecations)
  - [Classic API Privilege Requirements](https://developer.jamf.com/jamf-pro/docs/classic-api-minimum-required-privileges-and-endpoint-mapping).

- Securely document the following values as they will be needed in the upcoming sections
  - clientId, clientSecret

## Creating secret template for Jamf Accounts 

### Jamf Client Credentials Template

The following steps are required to create the Secret Template for Jamf Discovery Account:

- Log in to the Delinea Secret Server 
- Navigate to ***Administration*** -> ***Secret Templates***
- Click on ***Create / Import Template***
- Click on ***Import***
- Copy and Paste the XML in the [Jamf Client Credentials Template](./Templates/Jamf%20Client%20Credentials.xml)
- Click on ***Save***

### Jamf User Account Template

The following steps are required to create the Secret Template for Jamf Users:

- Log in to the Delinea Secret Server 
- Navigate to ***Administration*** -> ***Secret Templates***
- Click on ***Create / Import Template***
- Click on ***Import***
- Copy and Paste the XML in the [Jamf User Template](./Templates/Jamf%20User%20Account.xml)
- Click on ***Save***

## Create secret in Secret Server for the Jamf Client Credentials Account
 
- Log in to the Delinea Secret Server 
- Navigate to ***Secrets***
- Click on ***Create Secret***
- Select the template created in the [earlier step](#Jamf-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - ***Secret Name:*** Jamf API Account or other descriptive name
    - ***tenant-url:*** Jamf base workspace url with no trailing slash, example ```https:\\yourserver.jamfcloud.com```
  - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - ***Client-id:***
    - ***client-secret:***
    - ***admin-roles:***
    - ***Service-Account-Group-Ids:***
  - Click ***Create Secret***

### Admin Roles and Service Account Group Ids
- The **admin-roles** field will contain a comma-separated list of roles you designate as **adminstrators**. 
- Example: ```ADMINISTRATOR,CUSTOM```
  > [!INFO]
  > [For more information on Jamf designated application Roles](https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Jamf_Pro_User_Accounts_and_Groups.html).
  
- The **Service-Account-Group-Ids** field will contain a comma-separated list of GroupIds you designate as **service accounts**. This assumes you have allocated and assigned groups specifically for service accounts. 
  Example: ```5,17,23```
> [!IMPORTANT]
> Reference Service Account **Group IDs** and not the group names.

## Next Steps

Once the tasks above are completed you can now proceed to create the [password changer](./RemotePasswordChanger/readme.md) and then the [discovery scanner](./Discovery/readme.md) 


