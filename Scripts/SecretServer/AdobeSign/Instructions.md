Adobe Acrobat Sign Connector base configuration

  

This connector provides the following functions

  

- Discovery of Local Accounts
- Discovery of Account Admin Accounts
- Discovery of Service Accounts

  

Follow the Steps below to complete the base setup for the Connector.

  

## Prepare Authentication

  

## Adobe Sign Integration Key

  

This connector utilizes Adobe Sign integration key to authenticate API calls.

  

Follow the instruction to create and Integration Key.

  

[here] (https://helpx.adobe.com/sign/kb/how-to-create-an-integration-key.html)

​

### Prerequisites

  

- Access to a Adobe Sign instance with administrative privileges.

- A generated Adobe Sign Integration Key

  

## Creating secret template for Adobe Sign Accounts

  

### Adobe Sign User Account Template

  

The following steps are required to create the Secret Template for ServiceNow Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Adobe Sign Account.xml File](./Templates/Adobe%20Sign%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Adobe Sign Integration Key Template

  

The following steps are required to create the Secret Template for Adobe Sign Integration Key:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Adobe Sign Integration Key.xml File](./Templates/Adobe%20Sign%20Integration%20Key.xml)

- Click on Save

- This completes the creation of the Integration Key template

  
  

## Create Secret in Secret Server for the Adobe Sign Privileged Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#adobe-sign-integration-key-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example Adboe Sign API Account )

- tenant-url (Adobe Sign base url with no training slash ex. https://api.na1.adobesign.com)

- Search Mode (Default mode searches for Account Admin & Local Accounts. Advanced Mode searches for Service Account as well as Account Admin and Local Accounts)

- SAML-Enabled (True or False value if SAML is enabled in your Adobe Sign instance. When SAML is disabled all accounts are Local Accounts. When SAML is enabled only the Accounts with the role of Account Admin will be Local Accounts.)

- Service-Group (Add a comma separated  group name/Group id key value pair what contains Service Accounts)
Example:
	- ServiceAccounts=CBJCHBCAABAADKXZhgzxczxxczdXp9KbAFLPdSF4Qm 
	-  ServiceAccounts=CBJCHBCAABAADKXZhgzxczxxczdXp9KbAFLPdSF4Qm ,ServiceAccounts2=AADKXZhgzxczxxczdXp9KbAFLPdSF4

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Adobe Sign Privilaged Account

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)