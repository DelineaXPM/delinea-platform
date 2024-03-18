# Github Connector base configuration

  

This connector provides the following functions

  

- Discovery of Github User Accounts in a given Organization

  

## Not currently available

- Remote Password Changing Github users

- Heartbeat (verifying credentials)

  

Follow the Steps below to complete the base setup for the Connector

  

# Prepare User Token Authentication

  

## OAuth User Token Flow in Github

  

This connector utilizes a user token that is granted at the organization level. This flow is typically used for Service-to-server API requests where the service itself needs to authenticate and interact with Github APIs.

​

### Prerequisites

  

- Login to a Github instance with administrative privileges (i.e. a user who has a RO systems administrator role).

- User token generated from Github

- Basic understanding of Personal Access Token authentication and Github administration.

  

## Create a Personal Access Token

  

- Create a personal access for for programmatic Discovery found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

  

*** For more information click [here](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization#restricting-access-by-personal-access-tokens-classic).

  

- Document the following values as they will be needed in the upcoming sections

- Github personal access token

- Go to Settings > Developer Settings > Tokens (classic) > Generate token

- Make sure the scopes selected are:

- read:user

- read:organization

- Ensure that the token is configured for SAML or an error will appear when using the token:

- {"message":"Resource protected by organization SAML enforcement. You must grant your Personal Access token access to this organization.}
  

# Creating Secret templates for Github Accounts

  

### Github User Account Template

  

The following steps are required to create the Secret Template for Github Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Github User Account Template File](./Templates/Github%20User%20Account%20Template.xml).

- Click on Save

 

### Github Integration Key Template

  

The following steps are required to create the Secret Template for Github Integration Key Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Github Integration Key Template File](./Templates/Github%20Integration%20Key%20Template.xml).

- Click on Save

## Create secret in Secret Server for the Github Integration Key

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [above](#github-integration-key-template).

- Fill out the required fields with the information from the application registration:

	- **Secret Name:** (for example Github Integration Key )

	- **Organization:** Name if the Github Organization (i.e. https://github.com/MyOrg would be MyOrg)

	- **Access Token:** (created in the task [above](#create-a-personal-access-token))
	
	-  Search Mode  
		- Advanced - Return Admin and Service Accounts flag
		- Basic - Return basic information for Local Accounts
	
	- **Service Account Teams:**  (Comma Separated list of Teams that are considered Service)Accounts)

- Click Create Secret


Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md).