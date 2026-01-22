# ServiceNow Connector Overview

This connector provides the following functions:  

- Discovery of Accounts
- Remote Password Changing ServiceNow Accounts
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

## Prepare Oauth Authentication

## OAuth Client Credentials Flow in ServiceNow

This connector utilizes an OAuth 2.0 application in ServiceNow using the client credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with ServiceNow APIs.
​
### Prerequisites

- Access to a ServiceNow instance with administrative privileges.
- Basic understanding of OAuth 2.0 and ServiceNow administration.

## Create an OAuth Application Registry

- Create an OAuth application registry using the following method:
  - Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and client secret that the client needs to access the restricted resources on the instance

For more information click [here](https://docs.servicenow.com/bundle/vancouver-platform-security/page/administer/security/task/t_SettingUpOAuth.html).

- Document the following values as they will be needed in the upcoming sections:
  - clientId, clientSecret, username, and password
  - The username and password should be the credential that has the permissions to Discover Users and Change their Passwords

## Creating Secret Template for ServiceNow Accounts 

### ServiceNow User Account Template

The following steps are required to create the Secret Template for ServiceNow Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ServiceNow User Template File](./Templates/ServiceNow%20User%20Template.xml)
- Click on Save

### ServiceNow Privileged Account Template

The following steps are required to create the Secret Template for ServiceNow Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ServiceNow Privileged Template File](./Templates/ServiceNow%20Privileged%20Account%20Template.xml)
- Click on Save

## Create Secret in Secret Server for the ServiceNow Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [above](#servicenow-privileged-account-template).
- Fill out the required fields with the information from the application registration
    - **Secret Name:** (for example ServiceNow API Account )
    - **tenant-url:** (ServiceNow base url with no trailing slash)
    - **Username:** (Created in the create App Registration [above](#create-an-oauth-application-registry))
    - **Password:** (Created in the create App Registration [above](#create-an-oauth-application-registry))
    - **Client-id:** (Created in the create App Registration [above](#create-an-oauth-application-registry))
    - **client-secret:** (Created in the create App Registration [above](#create-an-oauth-application-registry))
    - **Admin-Roles:** add a comma separated list of all roles that are considered to be an administrative user in the format of - role Name=role_sys_id (Example: admin=2831a114c611228501d4ea6c309d626d)
    - **Service-Account-Group-Ids:** add a comma separated list of all groups that are considered to be a Service Account in the Service-Account (Example: Engine Admins=c38f00f4530360100999ddeeff7b1298)
  - Click Create Secret
  
## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)