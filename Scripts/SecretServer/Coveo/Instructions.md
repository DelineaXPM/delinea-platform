# Coveo Connector Core Configuration

This connector provides the following functions:

- Discovery of Coveo User (Standard, Service & Administrator) Accounts in a given Tenant

## Not currently available
- Remote Password Changing Coveo users
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

# Prepare OAuth Authentication
OAuth Authentication for API is only allowed for users with the Account Administrators role permission.

## OAuth Client Credentials Flow in Coveo

This connector utilizes an OAuth authentication (using an API Key) in Coveo using the bearer token grant type. This flow is the only available method used for server-to-server API requests where the application itself needs to authenticate and interact with the Coveo APIs.
​
### Prerequisites

- Access to a Coveo instance with administrative privileges.
API Key with the the required privileges.

## Create an OAuth Application Registry

- Have, or create, a new API Key that has an Account Administrator role permission.  
- 
Document the following values as they will be needed in the upcoming sections
  - API Key


# Creating secret template for Coveo Accounts 

### Coveo User Account Template

The following steps are required to create the Secret Template for Coveo Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Coveo User Template.xml File](./Templates/Coveo%20User%20Secret%20Template.xml).
- Click on Save
- This completes the creation of the User Account template

### Coveo Discovery Account Template

The following steps are required to create the Secret Template for Coveo Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Coveo Discovery Account Template.xml File](./Templates/Coveo%20Discovery%20Secret%20Template.xml).
- Click on Save
- This completes the creation of the Coveo Account templates


## Create secret in Secret Server for the Coveo Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#coveo-discovery-account-templatee).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Coveo Discovery Account )
    - tenant-url (Coveo base workspace url with no trailing slash)
    - Organization-ID 
   - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - API-Key
    - Admin-Account-Groups
    - Service-Account-Groups
- Click Create Secret
  - For additional information regarding which admin and service account roles are supported, refer to the table and examples below.
  - This completes the creation of a secret in Secret Server for the Coveo Discovery Account


## Coveo User Role Definitions
- Admin-Account = Indicates whether the user is an Admin of the current workspace.  Per documentation, only Administrators can use the API.
- Service-Account = Indicates whether the user is a service account user.
- Local-Account = Indicates whether the user is an active local user.

Use the following comma-separated syntax to define what constitutes an "Admin" or "Service Account". These fields can be used to tailor your results of discovered users accordingly. **These examples are provided as a way to demonstrate syntax and formatting, not necessarily as a recommendation.**
### Example 1
- "team1=conventional_unhinge, tan_constitutionally"
### Example 2
- "team2=catacomb_playback, analogue_renown"


## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md).


