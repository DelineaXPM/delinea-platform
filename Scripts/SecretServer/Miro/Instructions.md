Miro Connector Overview

This connector provides the following functions  

- Discovery of Local Accounts along with determining Admin and Service Accounts


Follow the Steps below to complete the base setup for the Connector

## Prepare Authentication

## Miro API Access Key

This connector utilizes Miro API Access Keys to authenticate API calls.  

Follow the instruction to create and API Access Key.

- Create a Developer team in Miro (https://developers.miro.com/docs/create-a-developer-team)
- Create your app in Miro (https://developers.miro.com/docs/rest-api-build-your-first-hello-world-app#step-1-create-your-app-in-miro)
- Configure your app in Miro (https://developers.miro.com/docs/rest-api-build-your-first-hello-world-app#step-2-configure-your-app-in-miro)
- Install your app in Miro (https://developers.miro.com/docs/rest-api-build-your-first-hello-world-app#step-3-install-the-app)
- Token Permissions
  - team:read
  - organizations:read
  - organizations:teams:read


## Company Id

This connector requires you to obtain your Company Id in order to make some API calls.   

Follow the instructions to identify your Company Id.

- Login to Miro (https://miro.com/app/dashboard/)
- Click on your User Logo (Upper Right Corner)
- Click Settings
- Look at your current URL (ex. `https://miro.com/app/settings/company/3458764577228081192/user-profile/`)
- Company Id will be the number between '/company/' and '/user-profile/'
  - In example above the Company Id is 3458764577228081192


​
### Prerequisites

- Miro Enterprise License
- Access to a Miro instance with administrative privileges. (Company Administrator)
- A generated API Access Token
- Company Id

## Creating secret template for Miro Accounts 

### Miro User Account Template

The following steps are required to create the Secret Template for Miro Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Miro Account.xml File](./Templates/Miro%20Account.xml)
- Click on Save
- This completes the creation of the User Account template

### Miro Integration Key Template

The following steps are required to create the Secret Template for Miro Integration Key:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Miro Integration Key.xml File](./Templates/Miro%20Integration%20Key.xml)
- Click on Save
- This completes the creation of the Integration Key template


## Create secret in Secret Server for the Miro Privileged Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#Miro-integration-key-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example Miro API Account )
    - tenant-url (Miro base API url with no training slash  ex. https://api.miro.com")
    - Discovery Mode ('Default' mode searches for Local Accounts.  'Advanced' Mode searches for Admin Accounts and Service Accounts.)
    - Company Id (Directions for obtaining value above)
    - Access Token  (Directions for obtaining value above)
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the Miro Privileged Account

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md)