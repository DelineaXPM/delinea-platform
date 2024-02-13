# Prophecy.io account discovery

This document will cover adding a discovery source to Secret Server to allow reporting on accounts in a Prophecy.io instance.

## Prerequisites
- [Prophecy.io base pre-requisites](../instructions.md)
- [Prophecy.io Account Discovery Script](./prophecy.io_account_scanner.ps1) added to Secret Server

## Scanner Definition

- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** ->   
    - Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
    - Click ***Create Scanner***
    - Fill out the required fields with the information
        - ***Name:*** Prophecy.io Account Scanner
        - ***Description:*** (Example - Discovers Prophecy.io group memberships)
        - ***Active*** Checked
        - ***Scanner Type:***  Accounts
        - ***Base Scanner:*** PowerShell Discovery
        - ***Allow OU Input*** Checked
        - ***Input Template***: Host Range 
        - ***Output Template:***: Account (Basic) 
        - ***Script:*** *Prophecy.io Account Scanner* script uploaded in pre-requisites
        - ***Script Arguments:*** ```$[1]$username $[1]$password $[1]$notes ```
        - Click Save
        - This completes the creation of the Prophecy.io Account Scanner

### Create Discovery Source

- Navigate to ***Administration*** -> ***Discovery*** -> ***Discovery Sources***
- Click ***Create*** drop-down
- Click ***Empty Discovery Source***
- Enter the Values below
    - ***Name:*** Prophecy.io Account Discovery  (Or any name you would like but it will be needed for the custom report)
    - ***Site*** (Select Site Where Discovery will run) 
    - ***Source Type*** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click ***Add Scanner***
- Find ***Manual Host Range*** and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner*** 
- In the ***lines Parse Format*** Section Enter the word Prophecy.io (This value is not used, but there must be an entry on this line)
- Click ***Save***
- Click ***Add Child Scanner***
- Find ***Prophecy.io Account Scanner*** and Click ***Add Scanner***
- Select the Prophecy.io Account Scanner created above and Click ***Edit Scanner***
- Click the ***Add Secret*** Link under Credentials
- Search for the API Credential secret created in the [prerequisites](../instructions.md)
- Check the ***Use Site Run As Secret*** Check box to enable it
    ***Note Default Site run as Secret had to be set in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm) Section in the Delinea Documentation
- Click ***Save***
- Click on the ***Discovery Source*** tab and Click the Active check box
- This completes the creation of the discovery Source

### Custom Report

- Navigate to ***Reports*** in your instance and click the ***New Report** button
- Paste the contents of the [Prophecy.io custom report](./Prophecy.io-additional-data-report.sql) into the Report SQL box
  - Update line 19 to match the name of the Discovery Source created in the previous step if you chose a different Name  
    `WHERE ds.name = 'Prophecy.io Account Discovery' ` -> `WHERE ds.name = 'Your Custom Name' `
- Do not add a Chart
- Enter whatever you would like for the following items
  - Name 
  - Description
  - Category
  - Page Size
  - Use Database Paging
- ***Save*** the report
- Once Discovery runs this report will populate to show the members of the selected admin groups
