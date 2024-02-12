# Creating Secret Template for Box Accounts 

### Box User Account Template

The following steps are required to create the Secret Template for Box Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Box User Template File](./Box%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Box Discovery Account Template

The following steps are required to create the Secret Template for Box Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Box Discovery Account Template File](./Box%20Discovery%20Account.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Box Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [above](#Box-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Box Discovery Account)
    - tenant-url (base Box url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md#create-an-oauth-application-registry) Section
    - ClientId
    - ClientSecret
    - subjectType
    - subjectId
    - AdminRoles
    - Service-account-group-names
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Box Discovery Account

Additional information regarding Secret Templates and creating a secret can be found [here](./readme.md).

- The **AdminRoles** field will contain a comma-separated list of role designations set within Box, documented [here](https://support.box.com/hc/en-us/articles/4636533822483-Box-User-Types). 
  - Example: ```Admin,coadmin```

- The **Service-account-group-names** field will contain a comma-separated list of GroupNames you designate as **Service Accounts**. This assumes you have allocated and assigned groups specifically for demarking user-based service accounts. 
  - Example: ```SvcAccts,Service Accounts,API Accounts```
> [!IMPORTANT]
> Reference Service Account Group Names delimited by commas. 


