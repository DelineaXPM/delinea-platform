# Creating secret template for Intune Accounts 

### Intune User Account Template

The following steps are required to create the Secret Template for Intune Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Intune User Template.xml File](./Intune%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template


### Intune Discovery Account Template

The following steps are required to create the Secret Template for Intune Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Intune Discovery Credentials Template.xml File](./Intune%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Intune Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Intune-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Intune Discovery Account)
    - The following field values are as created in the [Create an OAuth Application Registry](..\instructions.md\#create-an-oauth-application-registry) Section
    - TenantId 
    - ClientId
    - ClientSecret
    - AdminRoles
    - Service-Account-Group-Names
    - LocalDomain
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Intune Discovery Account

- The **AdminRoles** field will contain a comma-separated list of roles you have designated as administrators set within Intune, with examples documented [here](https://learn.microsoft.com/en-us/mem/intune/fundamentals/role-based-access-control#built-in-roles). 
  - Example: ```Intune Role Administrator,Application Manager```
- The **Service-Account-Group-Names** field will contain a comma-separated list of **EntraID Group Names** you have designated as Intune Service accounts.
  - Example: ```Intune SvcAccounts```
- The **LocalDomain** field will contain the domain name you have designated as a Local user within EntraID. This is typically the suffix of your users' email address.
  - Example: ```devinstance.onmicrosoft.com```
> [!NOTE]
> The LocalDomain field only supports one domain name value.