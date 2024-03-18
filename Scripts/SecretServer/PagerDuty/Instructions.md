# PagerDuty Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts
- Discovery of Account Admin Accounts
- Discovery of Service Accounts

Follow the Steps below to complete the base setup for the Connector

## Prepare Authentication

## PagerDuty API Access Key

This connector utilizes PagerDuty API Access Keys to authenticate API calls.  

Follow the instruction to create and API Access Key.

[here] (https://support.pagerduty.com/docs/api-access-keys#section-generating-a-general-access-rest-api-key)
​
### Prerequisites

- Access to a PagerDuty instance with administrative privileges. (Owner or Global Admin Base Role)
- A generated API Access Key

## Creating secret template for PagerDuty Accounts 

### PagerDuty User Account Template

The following steps are required to create the Secret Template for PagerDuty Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [PagerDuty Account File](./Templates/PagerDuty%20Account.xml)
- Click on Save

### PagerDuty Integration Key Template

The following steps are required to create the Secret Template for PagerDuty Integration Key:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [PagerDuty Integration Key File](./Templates/PagerDuty%20Integration%20Key.xml)
- Click on Save

## Create secret in Secret Server for the PagerDuty Integration Key Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [above](#PagerDuty-integration-key-template).
- Fill out the required fields with the information from the application registration
    - **Secret Name:** (for example PagerDuty API Account )
    - **tenant-url:** (PagerDuty base API url with no training slash  example api.pagerduty.com)
    - **Discovery Mode:** ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin Accounts and Service Accounts.)
    - **SAML-Enabled:** (True or False value if SAML is enabled in your PagerDuty instance.  When SAML is disabled all accounts are Local Accounts.  When SAML is enabled we will only find accounts if 'Advanced' Discovery Mode is enabled.)
    - **Service-Group:** (Add a group name which contains Service Accounts)
  - Click Create Secret
 
## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)