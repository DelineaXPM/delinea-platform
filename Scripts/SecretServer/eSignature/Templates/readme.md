# Creating secret templates for Docusign Accounts 

### Docusign User Account Template

The following steps are required to create the Secret Template for Docusign Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Docusign User Template.xml File](./Docusign%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Docusign Discovery Account Template

The following steps are required to create the Secret Template for Docusign Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Docusign Discovery Account Template.xml File](./Docusign%20Discovery%20Account.xml)
- Click on Save
- This completes the creation of the User Account template


## Create secret in Secret Server for the Docusign Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#docusign-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Docusign Discovery Account)
    - tenant-url (base Docusign url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - audience-uri (**Important**: Do not include https// in the *aud* value!)
    - issuer
    - subject
    - privateKeyPEM
    - accountid
    - service-account-group-names
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Docusign Discovery Account

- The **Service-Account-Group-Ids** field will contain a comma-separated list of GroupNames you designate as **Service Accounts**. This assumes you have allocated and assigned groups specifically for demarking user-based service accounts. 
  Example: ```SvcAccts,Service Accounts,API Accounts```
> [!IMPORTANT]
> Reference Service Account Group Names delimited by commas. 


