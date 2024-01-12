# Okta - Delinea Integrations Package

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Remote Password Changing ServiceNow uiusers

- Heartbeats to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for the Connector

  

## Prepare Oauth Authentication

  

## OAuth Client Credentials Flow in Okta

  

This connector utilizes an OAuth 2.0 application in Okta with Credential Type Public key / Private key. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Okta APIs.

​

  

### Prerequisites

  

- Access to a Okta instance with administrative privileges.

Basic understanding of OAuth 2.0 and Okta administration.

  

## Create an OAuth Application

  

- Login to your Okta instance as a Super Admin

- Navigate to Applications > Applications

- Select a Sign-in method of **API Service** and Click

- Name your application (example: Secret Server API Service)

- click Save

- Under Client Credentials Click Edit

- For Client authentication Select Public key / Private key

- Select where to store the API Key

- Click Add Key and The Genearte New Key

- Select PEM from the Prive Key

  

**MAKE SURE TO COPY THE PRIVATE KEY**

  

- Click Save

- Under Okta API Scopes, Grant the Following

- okta.roles.read

- okta.users.manage

- okta.users.read

- Under Admin Roles, search for the Super Administrator role and click Add Assignment

- This completes the Application Creation

  

For further information about Oauth authentication in Okta please see the Okta Document found [Here](https://developer.okta.com/docs/guides/implement-oauth-for-okta/main/) or Contact your Okta support team.

  

## Create secret template for Okta Accounts

  

### Okta User Account Template

  

The following steps are required to create the Secret Template for Okta Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Cpoy and Paste the XML in the [Okta User.xml File](./Templates/Okta%20User.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Okta Privileged Account Template

  

The following steps are required to create the Secret Template for Okta Privileged Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Cpoy and Paste the XML in the [Okta Privileged Account.xml File](./Templates/Okta%20Privileged%20Acount.xml)

- Click on Save

- This completes the creation of the Privileged Account template

  
  

## Create Secret in Secret Server for the Okta Priviled Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#servicenow-privileged-account-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example Okta API Account )

- tenant-url (Okta base url with no training slash)

- The following field values are as created in the [Create OAuth Application](#create-an-oauth-application) Section

- Client-id

- key-id (Private Key Id for the created Certificate)

- Private-Key

- Admin-Roles add a comma seperted list of all roles that are considered to be an ministrative user in the format of - role Name=role_sys_id Example admin=2831a114c611228501d4ea6c309d626d

- Service-Account-Attributes add a comma seperted list of all User Attribute-Value pair that are considered to be a Service Account.t (Example)

employed=Null,

CustomAttribute=Service

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Okta Privileged Account

  

## Next Steps

  

Once the tasks above are completed you can now proceed to Create a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)