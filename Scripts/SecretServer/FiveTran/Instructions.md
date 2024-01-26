# FiveTran Connector Core Configuration

  

This connector provides the following functions:

  

- Discovery of FiveTran User (Standard, Service & Administrator) Accounts in a given Workspace

  

## Not currently available

- Remote Password Changing FiveTran users

- Heartbeats to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for the Connector

  


# Authentication and Authorization Disclaimer

  

The provided configurations are developed by using a static [user OAuth Access Token](https://fivetran.com/docs/rest-api/getting-started) for Authentication and Authorization. This is the only current method to authentcate and provide the neccessary access to complete this process. Due to a user challenge requirement with authorization code grant type, we have opted to use a static token for this automation integration. The supported grant types are:

- JSON Web Token Signed from an RSA key (256 bit encryption padded to PKCS11; This can change later as features are needed)

- Client Credentials

- Basic Authentication (64 base encoded key value pair)

- API Access Key

  
  

# Prepare API Access Key Authentication

  

  

## OAuth API Access Key Flow in Fivetran

  
  
  

This connector utilizes an API key authentication to interact with Fivetran. This will use the Basic OAUTH2 process by in which the API access key ID and value are base encoded and passed to get the bearer token.

  

​

  

### Prerequisites

  

  

- Login to a FiveTran instance with administrative privileges (i.e. a user who has a RO systems administrator role).

  

- API access key created in the FiveTran tenant

  

- Basic understanding of API Access Keys.

  

  

## Create an API Access Key

  

  

- Create an API Access Key for for programmatic Discovery found [here](https://fivetran.com/docs/rest-api/getting-started). This can be scoped to what endpoints are needed for the discovery.

  

- This should be scoped accordingly as well. Here are docs explaining it [here](https://fivetran.com/docs/using-fivetran/fivetran-dashboard/account-management/role-based-access-control).

  

*** For more information click [here](https://fivetran.com/docs/rest-api/getting-started/scoped-api-key-faq).

  
  
  

## What is needed

  
  
  

- Fivetran API Access Key

### Creating API Access Key 

- Login to Fivetran > Click your user name in your Fivetran dashboard > Click API Key > Click Generate API key

  

- Document the values of the API Access Key and API Secret as they will be needed in the upcoming sections

  

- Ensure the token is scoped properly for security purposes and follow the practice of privilege of least access
  

# Creating Secret Template for FiveTran Accounts

  

### FiveTran User Account Template

  

The following steps are required to create the Secret Template for FiveTran Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [FiveTran User Template.xml File](./Templates/FiveTran%20User%20Secret%20Template.xml).

- Click on Save

- This completes the creation of the User Account template

  

### FiveTran Discovery Account Template

  

The following steps are required to create the Secret Template for FiveTran Discovery Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [FiveTran Discovery Account Template.xml File](./Templates/FiveTran%20Discovery%20Secret%20Template.xml).

- Click on Save

- This completes the creation of the User Account template

  
  

## Create secret in Secret Server for the FiveTran Discovery Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#fivetran-discovery-account-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example FiveTran API Account )

- Discovery-Mode - Default/Advanced

- Default will not Return Admin, Service Account Detail

- Advanced will use Criteria entered Below

The following field values are as created in the [Create an API Access Key](#create-an-api-access-key) Section

- Tenant-url

- API-Key

- API-Secret

- Admin-Account-Teams

- FiveTran uses two random words which are dash-separated as IDs) and a Team Name . Values must be a comma separated List of TeamName=ID

  

Example:

  

1. team1=explre_tropically

2. team1=explre_tropically,team2=tan_constitutionally

- Service-Account-Teams

- See Examples Above

- Federated-Domains - Comma Separated List of Federated Domains

Example 1:

mydomain.com

  

Example 2:

mydomain.com,Mycompany.org

- Click Create Secret

- For additional information regarding which admin and service account roles are supported, refer to the table and examples below.

- This completes the creation of a secret in Secret Server for the FiveTran Discovery Account

  

# FiveTran User Roles

  

## FiveTran User Role Definitions

- Admin-Account-Teams = Indicates whether the user is an Admin of the current workspace. Per documentation, only Administrators can use the API.

- Service-Account-Teams = Indicates whether the user is a service account user.

- Federated-Domains = Indicates what Domains have been Federated the user is these Domains return a value of Local-Account = False.

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md).