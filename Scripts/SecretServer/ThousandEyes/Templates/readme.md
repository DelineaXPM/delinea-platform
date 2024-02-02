# Creating secret template for ThousandEyes Accounts 

### ThousandEyes User Account Template

The following steps are required to create the Secret Template for ThousandEyes Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ThousandEyes User Template.xml File](./ThousandEyes%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### ThousandEyes Discovery Account Template

The following steps are required to create the Secret Template for ThousandEyes Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [ThousandEyes Discovery Credentials Template.xml File](./ThousandEyes%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the ThousandEyes Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#ThousandEyes-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example ThousandEyes Discovery Account)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md#create-an-oauth-application-registry) Section
    - AccessToken
    - AdminRoles
    - Service-Account-Roles
    - LocalDomain
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the ThousandEyes Discovery Account

- The **AdminRoles** field will contain a comma-separated list of roles you have designated as administrators set within ThousandEyes, with examples documented [here](https://docs.thousandeyes.com/product-documentation/user-management/rbac/role-based-access-control-explained). 
  - Example: ```Account Admin,Organization Admin```
- The **Service-Account-Roles** field will contain a comma-separated list of roles you have designated as service accounts set within ThousandEyes, with examples documented [here](https://docs.thousandeyes.com/product-documentation/user-management/rbac/role-based-access-control-explained). 
  - Example: ```Service Account```
- The **LocalDomain** field will contain the email domain name you have designated as a Local user within ThousandEyes.
  - Example: ```userdomain.com```
> [!NOTE]
> The LocalDomain field only supports one domain name value.