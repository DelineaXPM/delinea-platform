## ShareFile Connector Overview

  

This connector provides the following functions

  

- Discovery of Local Accounts

- Discovery of Account Admin Accounts

- Discovery of Service Accounts

- Heartbeat for Local Accounts  

# Not Supported

- Remote Password Changing of Local Accounts

Follow the Steps below to complete the base setup for the Connector

  

## Prepare Authentication

  

## ShareFile API Access Key

  

This connector utilizes ShareFile API Access Keys to authenticate API calls.

  

Follow link to create and API Access Key.

  

[here] (https://api.sharefile.com/apikeys)

  

- Application - Name of Application using API Key (Eg. Secret Server)

- Redirect URI - leave blank

-  Click checkbox (It will fill in a default Redirect URI.)

  

Click **Generate API Key** button

​

### Prerequisites

  

- Access to a ShareFile instance with administrative privileges. (Owner or Global Admin Base Role)

- A generated API Access Key

  

## Creating secret template for ShareFile Accounts

  

### ShareFile User Account Template

  

The following steps are required to create the Secret Template for ShareFile Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [ShareFile Account.xml File](./Templates/ShareFile%20Account.xml)

- Click on Save

- This completes the creation of the User Account template

  

### ShareFile Privileged Account Template

  

The following steps are required to create the Secret Template for ShareFile Integration Key:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [ShareFile Integration Key.xml File](./Templates/ShareFile%20Privileged%20Account.xml)

- Click on Save

- This completes the creation of the Integration Key template

  
  

## Create Secret in Secret Server for the ShareFile Privileged Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#ShareFile-Privileged-account-template).

- Fill out the required fields with the information from the application registration

- Secret Name (for example ShareFile API Account )

- Tenant URL (ShareFile base API url with no training slash ex. api.ShareFile.com)

- Discovery Mode ('Default' mode searches for Local Accounts. 'Advanced' Mode searches for Admin Accounts and Service Accounts.)

- Federation Domains - Add a list of email domains which are being federated. Any account that doesn't have an email address that matches these domains will be considered a Local Account.

- Service-Group (Add a group name which contains Service Accounts)

- Click Create Secret

- This completes the creation of a secret in Secret Server for the ShareFile Privileged Account

  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and Remote Password Changing [Here](./RemotePasswordChanger/readme.md)