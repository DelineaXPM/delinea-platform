# Creating secret templates for Jamf Accounts 

### Jamf User Account Template

The following steps are required to create the Secret Template for Jamf Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Jamf User Template.xml File](./Jamf%20User%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Jamf Privileged Account Template

The following steps are required to create the Secret Template for Jamf Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Jamf Client Credentials.xml File](./Jamf%20Client%20Credentials.xml)
- Click on Save
- This completes the creation of the User Account template


## Create secret in Secret Server for the Jamf Client Credentials Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Jamf-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Jamf API Account )
    - tenant-url (Jamf base workspace url with no trailing slash, example ```https:\\yourserver.jamfcloud.com``` )
    - The following field values are as created in the [Create an OAuth Application Registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - Client-id
    - client-secret
    - admin-roles
    - Service-Account-Group-Ids
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Jamf Client Credentials.

  ### Admin Roles and Service Account Group Ids
- The **admin-roles** field will contain a comma-separated list of roles you designate as **Adminstrators**. For more information on Jamf designated application Roles, click [here](https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Jamf_Pro_User_Accounts_and_Groups.html).
  - Example: ```ADMINISTRATOR,CUSTOM```
- The **Service-Account-Group-Ids** field will contain a comma-separated list of GroupIds you designate as **Service Accounts**. This assumes you have allocated and assigned groups specifically for demarking service accounts. 
  Example: ```5,17,23```
> [!IMPORTANT]
> Reference Service Account Group IDs and not the group names.
