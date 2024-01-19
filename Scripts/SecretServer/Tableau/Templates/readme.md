# Creating secret templates for Tableau Accounts 

### Tableau User Account Template

The following steps are required to create the Secret Template for Tableau Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Tableau User Template.xml File](./Tableau%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Tableau Client Credentials Template

The following steps are required to create the Secret Template for Tableau Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Tableau Client Credentials Template.xml File](./Tableau%20Client%20Credentials.xml)
- Click on Save
- This completes the creation of the User Account template


## Create secret in Secret Server for the Tableau Client Credentials
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#tableau-client-credentials-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Tableau SiteName Client Credential)
    - tenant-url (base Tableau url with no trailing slash)
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - Clientid
    - clientsecret
    - admin-roles
    - service-account-group-names
    - content-url (This is your Site Name)
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Tableau Client Credentials
  > [!NOTE]
  > If you have multiple Tableau Sites to Discover, add appropriate secrets for each. Content-URL will be the name of your Site - for example: If https://yb.online.tableau.com/#/site/SiteNameHere/home is your home URL, SiteNameHere would be your Content-URL.

    ### Admin Roles and Service Account Group Names
- The **admin-roles** field will contain a comma-separated list of roles you designate as **Adminstrators** with no spaces. For more information on Tableau designated application Roles, click [Tableau Site Roles](https://help.tableau.com/current/server/en-us/users_site_roles.htm#tableau-site-roles-as-of-version-20181).
  - Available roles include: ```Creator, Explorer, ExplorerCanPublish, ServerAdministrator, SiteAdministratorExplorer, SiteAdministratorCreator, Unlicensed, ReadOnly, Viewer```
  - Example for **admin-roles**: ```SiteAdministratorCreator,SiteAdministratorExplorer```
- The **Service-Account-Group-Ids** field will contain a comma-separated list of GroupNames you designate as **Service Accounts**. This assumes you have allocated and assigned groups specifically for demarking user-based service accounts. 
  Example: ```SvcAccts,Service Accounts,API Accounts```
> [!IMPORTANT]
> Reference Service Account Group Names delimited by commas. This operation targets groups and users in a per-Site basis and will distinguish them within that Site Only.