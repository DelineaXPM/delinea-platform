# Creating secret template for Asana Accounts 

### Asana User Account Template

The following steps are required to create the Secret Template for Asana Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Asana User Template.xml File](./Asana%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Asana Discovery Account Template

The following steps are required to create the Secret Template for Asana Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Asana Discovery Account Template.xml File](./Asana%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Asana Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Asana-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Asana Discovery Account)
    - tenant-url (base Asana url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md#create-an-oauth-application-registry) Section
    - PAToken
    - service-account-name
    - DomainName
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Asana Discovery Account


- The **service-account-name** field will contain a comma-separated list of Naming conventions you designate as **Service Accounts**. This assumes you have allocated and assigned a naming convention specifically for demarking service accounts. 
  Examples to match naming conventions like *svc-accountName* and *ApplicationSvc2*: ```Svc-*,*svc*```
> [!IMPORTANT]
> A wildcard character (*) will be used to format the naming convention appropriately. Currently, the filter does **not** use Regular Expression and is not case sensitive.

- The **DomainName** field will contain a single domain for identifying users of a particular domain. All users not part of this domain will be considered "Local Accounts".
> [!NOTE]
> This field is matched from the domain of users' email address. For example, if the field value contains "Domain.com", any user's email with @domain.com will be matched (Local-Account = False) and all other domains will return Local-Account = True.