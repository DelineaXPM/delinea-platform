# PAN-OS Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts
- Remote Password Changer
- Heartbeats

Follow the Steps below to complete the base setup for the Connector
​
### Prerequisites

- Access to a PAN-OS instance with administrative privileges. 
- A Privileged Account used for Discovery and RPC.  This Privileged Account should have SuperUser Permissions.

## Creating secret template for PAN-OS Accounts 

### PAN-OS User Account Template

The following steps are required to create the Secret Template for PAN-OS Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [PAN-OS Account.xml File](./Templates/PAN-OS%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

## Create secret in Secret Server for the PAN-OS Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#PAN-OS-user-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example PAN-OS API Account )
    - Tenant-Url (PAN-OS base API url with no training slash  ex. https://firewall.localdomain)
    - Discovery-Mode ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin Accounts and Local Accounts.)
    - Username 
    - Password
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the PAN-OS Privileged Account

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) or Remote Password Changer [Here](./RemotePasswordChanger/readme.md)