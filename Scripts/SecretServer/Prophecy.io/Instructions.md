# Prophecy.io Connector Overview

This connector provides the following functions  

- Account Discovery :white_check_mark: 
- Password Changing (RPC) :heavy_multiplication_x:
- Password Validation (Heartbeat)  :heavy_multiplication_x:


## API Authentication via Personal Access Token
​
- Login to https://app.prophecy.io/ 
- Click on the ... icon in the lower left corner of the screen and choose the :gear: gear icon to open settings
- Click on the ***Access Tokens*** tab
- Click on the ***Generate Token*** button
- Give your Token a name that indicates it's purpose. *Delinea Discovery* for example
- Select a lifespan for the token that is inline with your security guidelines

## Create secret in Secret Server for the Prophecy.io Client Credentials
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the Password template 
- Fill out the required fields with the information from the application registration
    - ***Secret Name:*** Descriptive name (ex. Prophecy.io  Client Credential)
    - ***Resource:*** https://app.prophecy.io/api/md/graphql 
    - ***Password:*** Token Value from previous step
    - ***Notes:*** Comma separated list of groups to scan (ex. group1,group2)
  - Click Create Secret
  - *(Optional) if expiration is enabled for the template, open the settings tab and set the secret expiration to align with the value set above*
  - This completes the creation of a secret in Secret Server for the Prophecy.io Client Credentials

Once the tasks above are completed you can now proceed to create a [Discovery Scanner](./Discovery/readme.md) 


