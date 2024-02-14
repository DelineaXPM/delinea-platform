# Login VSI Connector Core Configuration

This connector provides the following functions:

- Discovery of Login VSI User (Standard, Service & Administrator) Accounts in a given Workspace.

## **Not** currently available
These functions may be available in the future. 
- Remote Password Changing Login VSI users
- Heartbeats to verify that user credentials are still valid

**NOTE** - LoginVSI does not currently support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.  
We are discussing issues with these functions with the vendor.

Follow the Steps below to complete the base setup for the Connector

### Prerequisites

- Access to a Login VSI instance with administrative privileges.
Basic understanding of what an Access Token is for remote authentication and Login VSI administration.

## Create an Application API Token

- Have, or create, a new API Token from the Login VSI Appliance Portal for a user who has an Account Administrator role permission.  For additional information, see the documentation for Login VSI.

- Document the following values as they will be needed in the upcoming sections
  - API Token Key
    - The API Token Key only shows when initially generated.  If you do no longer have access to the Secret, you can re-generate the Token
    - This script will, as needed, BASE64 encode the Key & Secret values and use them for authentication.  The values you place into Secret Server's secret field is the value taken directly from the Login VSI portal page.

# Creating secret template for Login VSI Accounts 

### Login VSI Discovery Account Template

The following steps are required to create the Secret Template for Login VSI Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Copy and Paste the XML in the [Login VSI Discovery Template.xml File](./Templates/LoginVSI%20Secret%20Template%20for%20Discovery.xml).
  - Click on Save
- This completes the creation of the Discovery Account template

## Create secret in Secret Server for the Login VSI Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#create-secret-in-secret-server-for-the-login-vsi-discovery-account).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example, Admin1 \ Login VSI API Account )
    - Discovery Mode (Not used currently by the integration)
    - Base URL
    - API Access Token
    - Admin Groups
    - Service Groups
- Click Create Secret
  - For additional information regarding which admin and service account roles are supported, refer to the table and examples below.
  - This completes the creation of a secret in Secret Server for the Login VSI Discovery Account

## Login VSI User Role Definitions
- Admin-Account = Indicates whether the user is an Admin of the current workspace. 

- Service-Account = Indicates whether the user is a service account user.
- Local-Account = Indicates whether the user is an active local user.

Use the following comma-separated syntax to define what constitutes an "Admin" or "Service Account". These fields can be used to tailor your results of discovered users accordingly. **These examples are provided as a way to demonstrate syntax and formatting, not necessarily as a recommendation.**
### Example: Define a group as an Admin Group.
- "Admin Group"
### Example: Define 2 groups as Service User Groups.
Have 2 group names, comma-separated, like shown here:
- "Service Users, Service Users 2"

## Next Steps

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md).


