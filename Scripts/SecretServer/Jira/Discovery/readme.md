# Jira account discovery

This document will cover adding a discovery source to Secret Server to allow reporting on administrative Atlassian accounts in a Jira instance. 

## Prerequisites
- [Jira base pre-requisites](./readme.md)
- [Jira Account Discovery Script](./Discovery/jira-account-discovery.ps1) added to Secret Server

## Scanner Definition

- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> 
    - Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
    - Click ***Create Scanner***
    - Fill out the required fields with the information
        - ***Name:*** Jira Local Account Scanner
        - ***Description:*** (Example - Discovers Jira Local User Accounts)
        - ***Active*** Checked
        - ***Scanner Type:***  Accounts
        - ***Base Scanner:*** PowerShell Discovery
        - ***Allow OU Input*** Checked
        - ***Input Template***: Host Range 
        - ***Output Template:***: Account (Basic) 
        - ***Script:*** Jira Local Account Discovery script uploaded in pre-requisites
        - ***Script Arguments:*** ```$[1]$Username $[1]$Password $[1]$URL $[1]$notes ```
        - Click Save
        - This completes the creation of the Jira Local Account Scanner

### Create Discovery Source

- Navigate to ***Administration*** -> ***Discovery*** -> ***Discovery Sources***
- Click ***Create*** drop-down
- Click ***Empty Discovery Source***
-Enter the Values below
    - ***Name:*** Jira Account Discovery  (Or any name you would like but it will be needed for the custom report)
    - ***Site*** (Select Site Where Discovery will run) 
    - ***Source Type*** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click ***Add Scanner***
- Find ***Jira Base URL*** and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner*** 
- In the ***lines Parse Format*** Section Enter the word Jira (This value is not used, but there must be an entry on this line)
- Click ***Save***

- Click ***Add Scanner***
- Find ***Jira Local Account Scanner*** and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner***
- Click ***Edit Scanner***
- Click the ***Add Secret*** Link
- Search for the API Credential secret created in the [prerequisites](./instructions.md)
- Check the ***Use Site Run As Secret*** Check box to enable it
    ***Note Default Site run as Secret had to be set in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box
- This completes the creation of the discovery Source

### Custom Report

- Navigate to ***Reports*** in your instance and click the ***New Report** button
- Paste in the contents of the [Jira custom report](./Jira-additional-data-report.sql) into the Report SQL box
  - Update line 19 to match the name of the Discovery Source created in the previous step if you chose a different Name  
    `WHERE ds.name = 'Jira Account Discovery` -> `WHERE ds.name = 'Your Custom Name`
- Do not add a Chart
- Enter whatever you would like for the following items
  - Name 
  - Description
  - Category
  - Page Size
  - Use Database Paging
- ***Save*** the report
- Once Discovery runs this report will populate to show the members of the selected admin groups
