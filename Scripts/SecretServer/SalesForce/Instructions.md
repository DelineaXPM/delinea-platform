 SalesForce Connector Overview

This connectore provides the following functions  

- Discovery of Local Accounts
- Remote Password Changing ServiceNow uiusers
- Heartbeats Comming by end of 1st quarter) to verify that user credentials are still valid
  For a tempoirary simulated Heartbeat process Please contact Delinea Account Manager to possible rngae Professional Services

Follow the Steps below to complete the base setup for the Connector

## Prepare Oauth Authentication

## OAuth Client Credentials Flow in SalesFoprce

This connector utilizes an OAuth 2.0 application in ServiceNow using the client credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with ServiceNow APIs.
​
### Prerequisites

- Access to a ServiceNow instance with administrative privileges.
Basic understanding of OAuth 2.0 and ServiceNow administration.

## Create a Connected App with Oath enabled

***Note these directions may be different in Lihjyning UI**
- Login to your SalesForce Tenant as an administrator
- From the setup menu go Apps > App Manager 
- Click on New Connected app and Set the following settings - Any settings not Lister here should be left blanck unless your organization has advance knowledge
  - Connected App Name - Example Secre Server API Accesdsd
  - API Nmae - Make the same as the Connected App Name
  - Connected App Name - Enter The apprpriate Contatc or Distribution list
  - Enable OAuth Settings	- Checked
  - Enable for Device Flow - Checked
  - Callback URL - <Your Instance Base URL>/oauth2/callback
  - Selected OAuth Scopes

        Manage User Data Via APIs
        Perform Requests at Anytime
  - Require Secret for Web Server Flow - Checked
  - Require Secret for Refresh Token Flo - Checked
  - Enable Client Credentials Flow - Checked
  - Enable Authorization Code and Credentials Flow	 - Checked
  - Save the Aplication
  - in the Enable Authorization Code and Credentials Flow. Click	 **Mange Cunsumer Details**
  - Generate and Document a New Client-Secret and Client Id
- This concludes teh Creation of the Connected App for Oauth

For more information on Connected Apps you can click [Here](https://salesforce.stackexchange.com/questions/40346/where-do-i-find-the-client-id-and-client-secret-of-an-existing-connected-app) pr contact your SalesFore Supprt Team



## Creating secret template for SalesForce Accounts 

### SalesForce User Account Template

The following steps are required to create the Secret Template for ServiceNow Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Cpoy and Paste the XML in the [SalesForce User Template.xml File](./Templates/SalesForce%20User%20Template.xml)
- Click on Save
- This completes the creation of the User Account template

### ServiceNow Privileged Account Template

The following steps are required to create the Secret Template for ServiceNow Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Cpoy and Paste the XML in the [SalesForce Privileged Template.xml File](./Templates/SalesForce%20Privileged%20Account%20Template.xml)
- Click on Save
- This completes the creation of the Privileged Account template


## Create secret in Secret Server for the SalesForce Priviled Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the template created in the earlier step [Above](#servicenow-privileged-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example SalesForce API Account )
    - SFDC-URL (SalesForce base url with no training slash)
    - The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    `- Username (User assigended profile 	Salesforce API Only System Integrations 
    `- Password Enter the password for the user account
    - Client-id
    - client-secret
  - Admin-Roles add a comma seperted list of all roles that are considered to be an ministrative user in the format of - role Name=role_sys_id Example admin=2831a114c611228501d4ea6c309d626d
  - Service-Account-Group-Ids add a comma seperted list of all groups that are considered to be a SZervice Account in the Service-Account (Example) Engine Admins=c38f00f4530360100999ddeeff7b1298)
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the ServiceNow Priviled Account

## Next Steps

Once the tasks above are completed you can now proceed to creat a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)