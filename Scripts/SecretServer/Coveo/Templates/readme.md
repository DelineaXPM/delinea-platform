# Creating secret templates for Coveo Accounts 

### Coveo User Account Template

The following steps are required to create the Secret Template for Coveo Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Coveo User Template.xml File](./Coveo%20User%20Secret%20Template.xml)
- Click on Save
- This completes the creation of the User Account template

###  Coveo Discovery Account Template

The following steps are required to create the Secret Template for Coveo Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Coveo Discovery Account Template.xml File](./Coveo%20Discovery%20Secret%20Template.xml)
- Click on Save
- This completes the creation of the User Account template


## Create secret in Secret Server for the Coveo Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#coveo-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Coveo API Account )
    - Workspace Name
    - workspace-url (Coveo base workspace url with no trailing slash)
- The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - OAuthToken
    - admin-roles
    - svcacct-roles
- Click Create Secret
  - For additional information regarding which admin and service account roles are supported, refer to the table and examples below.
  - This completes the creation of a secret in Secret Server for the Coveo Discovery Account


##
### Coveo Role Definitions
```
- is_admin = Indicates whether the user is an Admin of the current workspace
- is_service = Indicates whether the user is an Owner of the current workspace.
- is_local =
```
Use the following comma-separated syntax to define what constitutes an "Admin" or "Service Account". These fields can be used to tailor your results of discovered users accordingly. **These examples are provided as a way to demonstrate syntax and formatting, not necessarily as a recommendation.**
### Example 1
- **admin-roles:** Is_admin=True,Is_Owner=True
- **svcacct-roles:** Is_app_user=True,Is_bot=True
### Example 2
- **admin-roles:** Is_admin=True,is_restricted=False
- **svcacct-roles:** Is_app_user=True,Is_bot=False,Is_admin=True