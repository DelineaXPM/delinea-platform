# Workday Connector base configuration

  

This connector provides the following functions

  

- Discovery of Workday Service, Local, and Admin accounts

- Remote Password Changing of a single user

  

## Not currently available


- Heartbeat (verifying credentials)

  

Follow the Steps below to complete the base setup for the Connector

For a detailed information on setting up your Workday tenant for use with this integration go [here](./Delinea%20Workday%20Integration%20-%20Setup%20Guide%20-%2020240215%20-%20v2.pdf)   

# Prepare JSON Web Token (JWT) Authentication

  

## OAuth JSON Web Token (JWT) Flow in Github

  

This connector utilizes a JSON Web Token authentication by using a decrypted RSA 256 bit private key to sign the JWT.

​

### Prerequisites

  

- Login to a Workday instance with administrative privileges To set up the following:

- OAUTH2 application that is selected to handle JWT Bearer authentication

- Basic understanding of JWT authentication and Workday administration.

- SOAP endpoint that will be user for the Password Change

- Token Endpoint set up for OAUTH2 authentication

- Integrate Service User that will be used as the account for auth

- Assign the public key cert to both the account credentials and to the OAUTH2 app

- Creation of the Report as a Service (RaaS) REST Endpoint (more information found [here](https://community.workday.com/sites/default/files/file-hosting/restapi/index.html).). The report needs to have the following fields: 

- **Security_Groups_group.Reference_ID**
- **Email** 
- **User_Name** 
- **Employee_ID**
  

## Follow and Understand the JWT Process

  

- Explanation of the various Auth processes in Workday found [here](https://community.workday.com/auth).

  

*** For more information on setup, look at these links: 

[Community Document 628676](https://community.workday.com/node/628676).

[Community Document 752269](https://community.workday.com/node/752269).

They can help provide understanding on how to create the necessary correct key files to be assigned
  

- Document the following values as they will be needed in the upcoming sections

- Client ID

- Integrated Service Username (NOT the UPN)

- Public Key Cert file assigned to BOTH the OAUTH2 app and Integrated Service User

- Decrypted Private PEM Key

- SOAP and OAUTH2 endpoints

- RaaS Endpoint configured with the necessary fields to be pulled from
  
 

## Creating Secret Templates for Workday Accounts

  

### Workday User Account Template

  

The following steps are required to create the Secret Template for Workday Users:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import

- Copy and Paste the XML in the [Workday Account Template file](./Templates/Workday%20Account.xml)

- Click on Save

  

### Workday Privileged Account Template

The following steps are required to create the Secret Template for Workday Privileged Account:

  

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Workday Privileged Template File](./Templates/Workday%20Privileged%20Account%20JWT.xml)

- Click on Save

- This completes the creation of the Privileged Account template

  
  

## Create secret in Secret Server for the Workday Privileged Account

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Secrets

- Click on Create Secret

- Select the template created in the earlier step [Above](#creating-secret-template-for-workday-accounts).

- Fill out the required fields

    - **Secret Name** (for example Workday Privileged Account )

    - **token-url** (The token uri that is for OAUTH2 authentication)


    - **Username** (The issuer of the token; in a non UPN Format)

    - **Client-id**  (Client ID of the OAUTH2 service account)

    - **RaaSEndpoint** (Report as a Service REST endpoint) 
    
    - **SOAP-Endpoint  (SOAP endpoint Root)

    - **Admin-Groups** (Target Admin account group membership String, but can be null and will pull all groups that have the phrase "admin" in them)

- Click Create Secret

## Next Steps

  

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)