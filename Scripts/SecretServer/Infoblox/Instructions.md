# Infoblox Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts
- Discovery of Account Admin Accounts
- Discovery of Service Accounts
- Remote Password Changing and Heartbeat for Local Accounts

Follow the Steps below to complete the base setup for the Connector
​
### Prerequisites

- Access to a Infoblox instance with administrative privileges. 
- A Privileged Account used for Discovery and RPC.  This Privileged Account should have SuperUser Permissions.
- A Privileged Account is used for Remote Password Changing. This Privileged Account should have SuperUser Permissions.
- Heartbeat requires each user to have permissions to make API calls to the Infoblox devices.


## Creating secret template for Infoblox Accounts 

### Infoblox User Account Template

The following steps are required to create the Secret Template for Infoblox Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Infoblox Account File](./Templates/Infoblox%20Account.xml)
- Click on Save


### Infoblox Privileged Account Template

The following steps are required to create the Secret Template for Infoblox Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Infoblox Privileged Account File](./Templates/Infoblox%20Privileged%20Account.xml)
- Click on Save
- Click on the **Mappings** tab and Click **Edit**
- Check on the **Enable RPC** Check Box to enable it
- Leave all fields except for **Password Type to use** as is
- Click the **Password Type to use** drop-down and select Infoblox WAPI Password Changer
- Map the fields as Below:
  
  - **Domain:** Tenant-URL
  - **Password:** Password
  - **Username:** Username
- Click on Save

## Create secret in Secret Server for the Infoblox Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [above](#infoblox-privileged-account-template)
- Fill out the required fields with the information from the application registration
    - **Secret Name:** (for example Infoblox API Account )
    - **Tenant-Url:** (Infoblox base API url with no training slash  ex. https://IPAM.localdomain)
    - **Discovery-Mode:** ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin and Service Accounts.)
    - **Username:** (Username of the Infoblox Privileged Account) 
    - Password** (Password of the Infoblox Privileged Account) 
    - Service-Account-Groups - User defined list of Groups that contain Service Accounts
  - Click Create Secret
 

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and a [RemotePassword Changer](./RemotePasswordChanger/readme.md)