# Lumapps Local Account  Discovery

## Pre-Requisistes
- [Lumapps base pre-requisites](./readme.md)
- [Lumapps Account Discovery Script](./Discovery/LumappsLocalAccountDiscovery.ps1) added to Secret Server
- [Lumapps Account Password Changer](./RemotePasswordChanger/readme.md) configured
 
## Create Lumapps Base URL Scan Template
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> ***Discovery Configuration Options*** -> ***Scanner Definition*** -> ***Scan Templates*** 
- Click ***Create Scan Template***
- Fill out the required fields with the information
    - ***Name:*** (Example: Lumapps Base URL)
    - ***Active:*** (Checked)
    - ***Scan Type:*** Host
    - ***Parent Scan Template:*** Host Range
    - ***Fields***
        - Change HostRange to ***BaseURL***
    - Click Save
    - This completes the creation of the Lumapps Local Account Scan Template Creation

## Create Lumapps Local Account Scan Template
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> ***Discovery Configuration Options*** -> ***Scanner Definition*** -> ***Scan Templates*** 
- Click ***Create Scan Template***
- Fill out the required fields with the information
    - ***Name:*** (Example: Lumapps Local Account User Account)
    - ***Active:*** (Checked)
    - ***Scan Type:*** Account
    - ***Parent Scan Template:*** Account(Basic)
    - ***Fields***
        - Change Resource to ***BaseURL***
        - Change Username to ***EmailAddress***
    - Click Save
    - This completes the creation of the Account Scan Template Creation

## Connect Password Changer to Scan Templates
- Open ***Administration*** -> ***Remote Password Changing*** -> ***Options*** -> ***Configure Password Changers***
- Select the Lumapps password changer created in the Remote Password Changing section
- Click ***Configure Scan Template***
- Click ***Edit***
- Select the Local Account Scan Template created in the previous section
- ***Fields***
  - ***BaseURL:*** Domain
  - ***EmailAddress:*** Username
  - ***Password:*** Password
- Click ***Save***

## Create Lumapps host range scanner
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> 
    - Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
    - Click ***Create Scanner***
    - Fill out the required fields with the information
        - ***Name:*** -> Lumapps Base URL
        - ***Description:*** (Example - Base scanner used to discover Lumapps Accounts)
        - ***Active*** Checked
        - ***Discovery Type:***  Host
    - ***Base Scanner:***  Host
    - ***Input Template***: Discovery Source
    - ***Output Template:***: Lumapps Base URL (Use Template that Was Created earlier)
    - Click Save
    - This completes the creation of the Saas Tenant Scanner

### Create Lumapps Local Account Scanner

- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> 
    - Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
    - Click ***Create Scanner***
    - Fill out the required fields with the information
        - ***Name:*** Lumapps Local Account Scanner
        - ***Description:*** (Example - Discovers Lumapps Local User Accounts)
        - ***Active*** Checked
        - ***Scanner Type:***  Accounts
        - ***Base Scanner:*** PowerShell Discovery
        - ***Allow OU Input*** Checked
        - ***Input Template***: Lumapps Base URL 
        - ***Output Template:***: Lumapps Local Account Account  
        - ***Script:*** Lumapps Local Account Discovery script uploaded in pre-requisites
        - ***Script Arguments:*** ```$[1]$apiurl $[1]$ApplicationID $[1]$ApplicationSecret $target $[1]$email $[1]$BaseURL ```
        - Click Save
        - This completes the creation of the Lumapps Local Account Scanner

### Create Discovery Source

- Navigate to ***Administration*** -> ***Discovery*** -> ***Discovery Sources***
- Click ***Create*** drop-down
- Click ***Empty Discovery Source***
-Enter the Values below
    - ***Name:*** Lumapps
    - ***Site*** (Select Site Where Discovery will run)
    - ***Source Type*** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click ***Add Scanner***
- Find ***Lumapps Base URL*** and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner*** 
- In the ***lines Parse Format*** Section Enter the OrganizationID
- Click ***Save***

- Click ***Add Scanner***
- Find ***Lumapps Local Account Scanner*** and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner***
- Click ***Edit Scanner***
- Click the ***Add Secret*** Link
- Search for the SaaS Client Credential template secret created in the prerequisites
- Check the ***Use Site Run As Secret*** Check box to enable it
    ***Note Default Site run as Secret had to be set in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box
- This completes the creation of the discovery Source



