SalesForce Connector Base Configuration

  

This connector provides the following functions

- Discovery of Local Accounts

- Remote Password Changing Salesforce users

## Not currently available

- Heartbeats Coming by end of 1st quarter) to verify that user credentials are still valid

For a temporary simulated Heartbeat process Please contact Delinea Account Manager to possibly engage Professional Services

  

Follow the Steps below to complete the base setup for the Connector

  

## Prepare Oauth Authentication

## OAuth Client Credentials Flow in SalesForce

This connector utilizes an OAuth 2.0 application in SalesForce using the client credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with SalesForce APIs.


### Prerequisites


- Access to a SalesForce instance with administrative privileges
- Basic understanding of OAuth 2.0 and SalesForce administration

## Create a Connected App with Oath enabled

***Note these directions may be different in Lightning UI**

- Login to your SalesForce Tenant as an administrator

- From the setup menu go Apps > App Manager

- Click on New Connected app and Set the following settings - Any settings not listed here should be left blank unless your organization has advanced knowledge of Connected Apps

- **Connected App Name:** - Example Secret Server API Access

- **API Name:** Make the same as the Connected App Name

- **Contact Email:** Enter The appropriate Contact or Distribution list

- **Enable OAuth Settings:** Checked

- **Enable for Device Flow:** Checked

- **Callback URL:** <Your  Instance  Base  URL>/oauth2/callback

- **Selected OAuth Scopes:**
     
    - Manage User Data Via APIs

    - Perform Requests at Anytime

- **Require Secret for Web Server Flow"** Checked

- **Require Secret for Refresh Token Flow:** Checked

- **Enable Client Credentials Flow - Checked

- **Enable Authorization Code and Credentials Flow:** Checked

- Save the Application

- in the **Enable Authorization Code and Credentials Flow,** Click **Mange Consumer Details**

- Generate and Document a New Client-Secret and Client Id

- This concludes the Creation of the Connected App for Oauth

  

For more information on Connected Apps you can click [here](https://salesforce.stackexchange.com/questions/40346/where-do-i-find-the-client-id-and-client-secret-of-an-existing-connected-app) or contact your SalesFore Support Team

  
  
  

## Creating secret template for SalesForce Accounts

  

### SalesForce User Account Template

  

The following steps are required to create the Secret Template for Salesforce Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [SalesForce User Template File](./Templates/SalesForce%20User%20Template.xml)

- Click on Save
  

### Salesforce Privileged Account Template

  

The following steps are required to create the Secret Template for Salesforce Privileged Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [SalesForce Privileged Template File](./Templates/SalesForce%20Privileged%20Account%20Template.xml)

- Click on Save


  
  

## Create secret in Secret Server for the SalesForce Privileged Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on **Create Secret**

- Select the template created in the earlier step [above](#salesforce-privileged-account-template).

- Fill out the required fields:

    - **Secret Name:** (for example SalesForce API Account )

    - **SFDC-URL:** (SalesForce base url with no training slash)

    - **Client-id:** (Client-id created [above](#oauth-client-credentials-flow-in-salesforce))

    - **Client-Secret:** (Client=Secret created [above](#oauth-client-credentials-flow-in-salesforce))

    - **Admin-Account-Criteria:** add a comma separated list of all profiles that are considered to be an ministrative user.

    - **Service-Account-Criteria:** add a comma separated list of all profiles that are considered to be a Service Account )

    - **Domain-Acct-Criteria:** A comma separated list of domains that are considered to be federated
- Click Create Secret
  

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)