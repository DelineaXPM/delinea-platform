# Zoom Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts
- Discovery of Account Admin Accounts
- Discovery of Service Accounts

**NOTE** - Heroku does not support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.  

Follow the Steps below to complete the base setup for the Connector

## Prepare Authentication

## Zoom API Access Key

This connector utilizes Zoom API Access Keys to authenticate API calls.  

Follow the instruction to create and API Access Key.

[Server-to-Server OAuth Starter App] (https://developers.zoom.us/docs/internal-apps/#enable-the-server-to-server-oauth-role)

[Create a Server-to-Server OAuth App] (https://developers.zoom.us/docs/internal-apps/create/)

​
### Prerequisites

- Access to a Zoom instance with administrative privileges. 
- A generated API Access Key

## Creating secret template for Zoom Accounts 

### Zoom User Account Template

The following steps are required to create the Secret Template for Zoom Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Zoom Account.xml File](./Templates/Zoom%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Zoom Integration Key Template

The following steps are required to create the Secret Template for Zoom Integration Key:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Zoom Integration Key.xml File](./Templates/Zoom%20Integration%20Key.xml)
- Click on Save
- This completes the creation of the Integration Key template


## Create secret in Secret Server for the Zoom Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Zoom-integration-key-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Zoom API Account )
    - Tenant-Url (Zoom base API url with no training slash  ex. https://api.Zoom.us)
    - Discovery-Mode ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin Accounts and Service Accounts.)
    - Account-Id (Zoom Account Id.  Obtained by creating an App in the Zoom Marketplace )
    - Client-Id (Obtained by creating an App in the Zoom Marketplace )
    - Client-Secret (Obtained by creating an App in the Zoom Marketplace )
    - Federation-Domains - Add a list of email domains which are being federated.  Any account that doesn't have an email address that matches these domains will be considered a Local Account.  
    - Service-Account-Groups (Add a group name which contains Service Accounts)
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Zoom Privileged Account

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)