
# Delinea Secret Server / EntraID/Azure Databricks Integration Base configuration

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Remote Password Changing of Local aUsers

- Heartbeats of Local Accounts to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for this integration. These steps are required to run any of the processes.

  

## Creating secret template for Databricks Accounts

  

## Creating secret templates for EntraID Accounts

  

### Creating secret template for User Accounts

  

The following steps are required to create the Secret Template for Databricks Advanced Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Databricks User Advanced.xml File](./templates/Databricks%20User%20Advanced.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Creating secret template for Databricks Privileged Acounts

  

The following steps are required to create the secret template for the application registration:

- Log in to the Delinea Secret Server

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Copy and Paste the XML in the [Databricks Privileged Account.xml File](./Templates/Databricks%20Privileged%20Account.xml)

- Click on Save

- This completes the creation of the secret template

  

## Create secret in Secret Server for the Databrikcs Privileged Account

- Log in to the Delinea Secret Server

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Creating Secret Template for Privileged Account](#creating-secret-template-for-privileged-account) (in the example EntraID Application Identity)

- Fill out the required fields with the information from the application registration

- Secret Name (for example Databrikcs Privileged Account)

- Tenant-URL (The URL of your Azure Databricks workspace.)

- Client ID: Your Entra ID AD application's Client ID.

- Client Secret: Your DataBricks Oauth2 secret that was mapped to the Entra ID app.

- Admin-Criteria - hese are the Groups that will be used to identify an admin user in Databricks. These groups need to be comma separated of the Group Name.

Examples:

- admins

- admins,samplegroup

- SVC-Account-Criteria - These are the Groups that will be used to identify a Services

Account User in Databrikcs. These groups need to be Comma separated group names.

  

Examples:

- ServiceAccounts1

- ServiceAccounts1,ServiceAccounts2

- Click Create Secret