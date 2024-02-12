# Box Connector Overview

  

This connector provides the following functions:

  

- Discovery of Box User Accounts in a given tenant

  

## Not currently available in Box Cloud

  

- Remote Password Changing Box users

- Heartbeat to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for the Connector

  

# Prepare Oauth Authentication

  

## OAuth Client Credentials Flow in Box

  

This connector utilizes an OAuth 2.0 application in Box using the Client Credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Box APIs.

More information can be found [here](https://developer.box.com/guides/authentication/oauth2/).

### Prerequisites

  

- Access to a Box instance with administrative privileges.

- Basic understanding of OAuth 2.0 and Box administration.

  

## Create an OAuth Application Registry

  

- Create an OAuth application registry using the following method:

- Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and client secret that the client needs to access the restricted resources on the instance.

  

**For more information and directions, click**  [here](https://developer.box.com/guides/authentication/oauth2/oauth2-setup/).

  

- Document the following values as they will be needed in the upcoming sections

- clientId, clientSecret, subject id, subject type

  

# Creating secret template for Box Accounts

  

### Box User Account Template

  

The following steps are required to create the Secret Template for Box Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Box User Template File](./Templates/Box%20User%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Box Discovery Account Template

  

The following steps are required to create the Secret Template for Box Discovery Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Box Discovery Account Template File](./Templates/Box%20Discovery%20Account.xml)

- Click on Save

- This completes the creation of the Discovery Account template

  
  

## Create secret in Secret Server for the Box Discovery Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [above](#Box-discovery-account-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example Box Discovery Account)

- The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section

  - ClientId

  - ClientSecret

  - subjectType

  - subjectId

  - AdminRoles

  - Service-account-group-names

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Box Discovery Account

  

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)