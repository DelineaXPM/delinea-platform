# Asana Connector Base Configuration

  

This connector provides the following functions

  

- Discovery of Asana User Accounts in a given tenant

  

## Not currently available in Asana Cloud

  

- Remote Password Changing Asana users

- Heartbeats to verify that user credentials are still valid

# Pre-Requisites   
This connector uses the Delinea.PoSH.Helper module. Follow the [installation instructions](../../Helper/readme.md) to add this module to all Distributed Engines or Web Servers that will be executing the scripts for this connector. 


Follow the Steps below to complete the base setup for the Connector

  

# Prepare Oauth Authentication

  

## OAuth Client Credentials Flow in Asana

  

Due to the requirement of user challenge interaction with the Client_Credentials grant type, this connector utilizes a Personal Access Token (PAT) Bearer grant type. The PAT will impersonate the scope and permissions of the assigned user on behalf of the application for what it needs to authenticate and interact with Asana APIs.

  

More information can be found [here](https://developers.asana.com/docs/authentication).

### Prerequisites

  

- Access to a Asana instance with administrative privileges.

- Basic understanding of API Keys and Asana administration.

  

## Create an OAuth Application Registry

  

- Create a Personal Access Token using the following method:

- Create and record the PAT using the user account with appropriate permissions that the client needs to access the restricted resources on the instance.

-  For more information and directions, click [here](https://developers.asana.com/docs/personal-access-token).

  

- Document the following values as they will be needed in the upcoming sections

  - PAT value

  

# Creating Secret Template for Asana Accounts

  

### Asana User Account Template

  

The following steps are required to create the Secret Template for Asana Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Asana User Template File](./Templates/Asana%20User%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Asana Discovery Account Template

  

The following steps are required to create the Secret Template for Asana Discovery Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Asana Discovery Account Template File](./Templates/Asana%20Discovery%20Credentials.xml)

- Click on Save

- This completes the creation of the Discovery Account template

  
  

## Create Secret in Secret Server for the Asana Discovery Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [above](#Asana-discovery-account-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example Asana Discovery Account)

- tenant-url (base Asana url with no trailing slash)

- The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section

- PAToken

- service-account-name

- DomainName

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Asana Discovery Account

  

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)