# Confluent Connector Overview

  

This connector provides the following functions

  

- Discovery of Confluent User Accounts in a given tenant

  

## Not currently available in Confluent Cloud

  

- Remote Password Changing Confluent users

- Heartbeats to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for the Connector


# Prepare Oauth Authentication

  

## OAuth Client Credentials Flow in Confluent

  

This connector utilizes an OAuth 2.0 application in Confluent using the Client Credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Confluent APIs.
​

### Prerequisites

  

- Access to a Confluent instance with administrative privileges.

- Basic understanding of OAuth 2.0 and Confluent administration.

  

## Create an OAuth Application Registry

  

- Create an OAuth application registry using the following method:

- Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and client secret that the client needs to access the restricted resources on the instance.

  

- Document the following values as they will be needed in the upcoming sections

- APIKey
- APISecret



# Creating secret template for Confluent Accounts

  

### Confluent User Account Template

  

The following steps are required to create the Secret Template for Confluent Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Confluent User Template File](./Templates/Confluent%20User%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Confluent Discovery Account Template

  

The following steps are required to create the Secret Template for Confluent Discovery Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Confluent Discovery Credentials Template File](./Templates/Confluent%20Discovery%20Credentials.xml)

- Click on Save

- This completes the creation of the Discovery Account template

  
  

## Create secret in Secret Server for the Confluent Discovery Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [above](#Confluent-discovery-account-template).

- Fill out the required fields with the information from the application registration

  - Secret Name (for example Confluent Discovery Account)

  - tenant-url (base Confluent url with no trailing slash)

- The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section

  - ApiKey

  - ApiSecret

  - AdminRoles

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Confluent Discovery Account

  

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)