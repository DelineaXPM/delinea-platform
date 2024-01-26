# Heroku Connector Base Configuration

  

  

This connector provides the following functions

  

  

- Discovery of Heroku User Accounts in a given team

  

** Note ** A different Discovery source and Access Key Secret and Discovery Source will be Needed for each Team

  

  

## Not currently available in Heroku Cloud

  

  

- Remote Password Changing Heroku users

  

- Heartbeats to verify that user credentials are still valid

  

  

Follow the Steps below to complete the base setup for the Connector

  

# Authentication and Authorization Disclaimer

  

The provided configurations are developed by using a static API access key for Authentication and Authorization. This the only current method to authentcate and provide the neccessary access to complete this process. Due to a user challenge requirement with authorization code grant type, we have opted to use a static token for this automation integration. The supported grant types are:

- JSON Web Token Signed from an RSA key (256 bit encryption padded to PKCS11; This can change later as features are needed)

- Client Credentials

- Basic Authentication (64 base encoded key value pair)

- API Access Key

  
  

# Prepare API Access Key Authentication

  

  

## OAuth API Access Key Flow in Heroku

  

  

This connector utilizes an API key authentication to interact with Heroku. This will use the OAUTH2 API access key process by which the Authorization bearer is in fact the API key value. This is also called "Direct Authorization" in Heroku.

  

​

  

### Prerequisites

  

  

- Login to a Heroku instance with administrative privileges (i.e. a user who has a RO systems administrator role).

  

- API access key created in the Heroku tenant

  

- Basic understanding of API Access Keys.

  

  

## Create an API Access Key

  

  

- Create an API Access Key for for programmatic Discovery.

  

- This token will mimic the user who granted the token's access. Look here for a direct authorization explanation [here](https://devcenter.heroku.com/articles/oauth#direct-authorization).

  

*** For more information click [here](https://devcenter.heroku.com/articles/oauth).

  
  
  

## What is needed

  
  
  

- Heroku API Access Key

  

- Login to Heroku > Click your user name in your Heroku dashboard in the top right > Click Account Settings > Click Reveal API Key

  

- Document the values of the API Access Key as they will be needed in the upcoming sections

  

- Ensure the token is from a service account with just the necessary permissions fro the discovery

  

# Creating secret template for Heroku Accounts

  

  

### Heroku User Account Template

  

  

The following steps are required to create the Secret Template for Heroku Users:

  

  

- Log in to the Delinea Secret Server (If you have not already done so)

  

- Navigate to Admin / Secret Templates

  

- Click on Create / Import Template

  

- Click on Import.

  

- Copy and Paste the XML in the [Heroku User Template.xml File](./Templates/Heroku%20User%20Account.xml)

  

- Click on Save

  

- This completes the creation of the User Account template

  

  

### Heroku Discovery Account Template

  

  

The following steps are required to create the Secret Template for Heroku Discovery Account:

  

  

- Log in to the Delinea Secret Server (If you have not already done so)

  

- Navigate to Admin / Secret Templates

  

- Click on Create / Import Template

  

- Click on Import.

  

- Copy and Paste the XML in the [Heroku Discovery Credentials Template.xml File](./Templates/Heroku%20Discovery%20Credentials.xml)

  

- Click on Save

  

- This completes the creation of the Discovery Account template

  

  

## Create secret in Secret Server for the Heroku Discovery Account

  

- Log in to the Delinea Secret Server (If you have not already done so)

  

- Navigate to Secrets

  

- Click on Create Secret

  

- Select the template created in the earlier step [Above](#heroku-discovery-account-template).

  

- Fill out the required fields with the information from the application registration

  

- Secret Name (for example Heroku Discovery Account)

  

- TeamName (Heroku team to be Discovered)

  

- The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section

  

- ApiKey

  

- AdminRoles - A single or comma separated list Roles to be considered Admin Accounts (ex: admin,Partial Admins)

  

- Service-Account-Prefixes A single or comma separated list username prefixes to be considered Admin Accounts (ex: svc,Service)

  

- Click Create Secret

  

- This completes the creation of a secret in Secret Server for the Heroku Discovery Account

  

## Next Steps

  

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)