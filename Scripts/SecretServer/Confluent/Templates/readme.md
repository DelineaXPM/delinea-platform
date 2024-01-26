# Creating secret template for Confluent Accounts 

### Confluent User Account Template

The following steps are required to create the Secret Template for Confluent Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Confluent User Template.xml File](./Confluent%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Confluent Discovery Account Template

The following steps are required to create the Secret Template for Confluent Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Confluent Discovery Credentials Template.xml File](./Confluent%20Discovery%20Credentials.xml)
- Click on Save
- This completes the creation of the Discovery Account template


## Create secret in Secret Server for the Confluent Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Confluent-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Confluent Discovery Account)
    - tenant-url (base Confluent url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md#create-an-oauth-application-registry) Section
    - ApiKey
    - ApiSecret
    - AdminRoles
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Confluent Discovery Account

- The **AdminRoles** field will contain a comma-separated list of roles you have designated as administrators set within Confluent, with examples documented [here](https://docs.confluent.io/cloud/current/access-management/access-control/rbac/predefined-rbac-roles.html#administration-roles). 
  - Example: ```AccountAdmin,OrganizationAdmin```