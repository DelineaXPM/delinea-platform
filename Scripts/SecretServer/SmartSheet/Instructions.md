## SmartSheet Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts
- Discovery of Admin Accounts
- Discovery of Service Accounts

## Not currently available in Heroku Cloud


- Remote Password Changing Heroku users

- Heartbeats to verify that user credentials are still valid

**NOTE** - SmartSheet does not support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.  

Follow the Steps below to complete the base setup for the Connector

## Prepare Authentication

## SmartSheet API Access Key

This connector utilizes SmartSheet API Access Keys to authenticate API calls.  

Follow the instruction for creating a Raw Token Requests

https://smartsheet.redoc.ly/#section/API-Basics/Raw-Token-Requests


### Prerequisites

- SmartSheet Enterprise License
- Access to a SmartSheet instance with administrative privileges. (System Admin)
- A generated API Access Token


## Creating secret template for SmartSheet Accounts 

### SmartSheet User Account Template

The following steps are required to create the Secret Template for SmartSheet Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [SmartSheet Account.xml File](./Templates/SmartSheet%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### SmartSheet Integration Key Template

The following steps are required to create the Secret Template for SmartSheet Integration Key:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [SmartSheet Integration Key.xml File](./Templates/SmartSheet%20Integration%20Key.xml)
- Click on Save
- This completes the creation of the Integration Key template


## Create secret in Secret Server for the SmartSheet Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#smartsheet-integration-key-template).
- Fill out the required fields with the information from the application registration
  - Secret Name (for example SmartSheet API Account )
  - tenant-url (SmartSheet base API url with no training slash  ex. https://api.smartsheet.com")
  - Discovery Mode ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin Accounts and Service Accounts.)
  - Access Token  (Directions for obtaining value above)
  - Federation Domains (Add a list of email domains which are being federated.  Any account that doesn't have an email address that matches these domains will be considered a Local Account.)  
  - Service-Group (Add a group name which contains Service Accounts)
- Click Create Secret
- This completes the creation of a secret in Secret Server for the SmartSheet Privileged Account

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and configure Remote Password Changing [Here](./RemotePasswordChanger/readme.md)