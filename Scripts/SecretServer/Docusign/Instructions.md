# Docusign Connector Overview

This connector provides the following functions  

- Discovery of Docusign User Accounts in a given site

## Not currently available in Docusign Cloud

- Remote Password Changing Docusign users
- Heartbeats to verify that user credentials are still valid


> [!NOTE]
> Due to deprecations to legacy authentication methods, basic user password authentication is no longer supported. We are unable to validate user passwords via heartbeat methods through impersonation and have created placeholders if this becomes available in the future. For additional information, please refer to [Docusign Support FAQs](https://support.docusign.com/s/articles/DocuSign-Developer-FAQs-eSignature-API?language=en_US).

Follow the Steps below to complete the base setup for the Connector

# Pre-Requisites   
This connector uses the Delinea.PoSH.Helper module. Follow the [installation instructions](../../Helper/readme.md) to add this module to all Distributed Engines or Web Servers that will be executing the scripts for this connector. 

# Prepare Oauth Authentication

## OAuth Client Credentials Flow in Docusign

This connector utilizes an OAuth 2.0 application in Docusign using the JWT Bearer grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Docusign APIs.
More information can be found [here](https://developers.docusign.com/docs/esign-rest-api/esign101/auth/). 
​
### Prerequisites

- Access to a Docusign instance with administrative privileges.
- Basic understanding of OAuth 2.0 and Docusign administration.

## Create an OAuth Application Registry

- Create an OAuth application registry using the following method:
  - Create an endpoint for external clients that want to access your instance. This creates an OAuth client application record and generates a client ID and integration key that the client needs to access the restricted resources on the instance.

***For more information and directions, click*** [here](https://developers.docusign.com/platform/auth/jwt/jwt-get-token/).

- Document the following values as they will be needed in the upcoming sections
  - clientId/integration key, subject user id, audience uri, PEM private key, tenant account id
> [!NOTE]
> Field descriptions and details can be found at [Docusign JWT structure and properties](https://developers.docusign.com/platform/auth/jwt/jwt-get-token/#see-details-jwt-structure-and-properties).

## Creating Secret Template for Docusign Accounts 

### Docusign User Account Template

The following steps are required to create the Secret Template for Docusign Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Docusign User Template File](./Templates/Docusign%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Docusign Discovery Account Template

The following steps are required to create the Secret Template for Docusign Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Docusign Discovery Account Template File](./Templates/Docusign%20Discovery%20Account.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Docusign Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [above](#docusign-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Docusign Discovery Account)
    - tenant-url (base Docusign url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - audience-uri (**Important**: Do not include https// in the *aud* value!)
    - issuer
    - subject
    - privateKeyPEM
    - accountid
    - service-account-group-names
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Docusign Discovery Account

Additional information regarding Secret Templates and creating a secret can be found [here](./Templates/readme.md).

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) 


