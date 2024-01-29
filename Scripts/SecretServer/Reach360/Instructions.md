# Reach360 Connector Overview

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Discovery of Account Admin Accounts

- Discovery of Service Accounts

  

## Not currently available in  Reach360

  

  

  

- Remote Password Changing Heroku users

  

  

- Heartbeats to verify that user credentials are still valid
  

Follow the Steps below to complete the base setup for the Connector

  

## Prepare Authentication

  

## Reach360 API Access Key

  

This connector utilizes Reach360 API Access Keys to authenticate API calls.

  

Follow the instruction to create and API Access Key.

  

[here] (https://community.articulate.com/articles/reach-360-manage-api-keys?_ga=2.123076619.1684117071.1706147647-1498146856.1706147647)

​

### Prerequisites

  

- Access to a Reach360 instance with administrative privileges.

- A generated API Access Key

  

## Creating secret template for Reach360 Accounts

  

### Reach360 User Account Template

  

The following steps are required to create the Secret Template for Reach360 Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Reach360 Account.xml File](./Templates/Reach360%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### Reach360 Integration Key Template

  

The following steps are required to create the Secret Template for Reach360 Integration Key:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Reach360 Integration Key.xml File](./Templates/Reach360%20Integration%20Key.xml)

- Click on Save

- This completes the creation of the Integration Key template

  
  

## Create secret in Secret Server for the Reach360 Privileged Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#Reach360-integration-key-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example Reach360 API Account )

- tenant-url (Reach360 base API url with no training slash ex. api.Reach360.com)

- Discovery Mode ('Default' mode searches for Local Accounts. 'Advanced' Mode searches for Admin Accounts and Service Accounts.)

- Federation Domains - Add a list of email domains which are being federated. Any account that doesn't have an email address that matches these domains will be considered a Local Account.

- Service-Group (Add a group name which contains Service Accounts)

- Click Create Secret

- This completes the creation of a secret in Secret Server for the Reach360 Privileged Account

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)