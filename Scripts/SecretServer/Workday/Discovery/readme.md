# Workday Account Discovery

## Create Discovery Source

### Create Workday Tenant Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: Workday Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields**
        - Change HostRange to tenant-url
    - Click Save
 

### Create Workday Account Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: Workday Account)
    - **Active:** (Checked)
    - **Scan Type:** Account
    - **Parent Scan Template:** Account(Basic)
    - **Fields**
        - Change Resource to **Domain**
        - Add field: Email (Leave Parent and Include in Match Blank)
        - Add field: Local-Account (Leave Parent and Include in Match Blank)
        - Add field: Admin-Account (Leave Parent and Include in Match Blank)
        - Add field: Service-Account (Leave Parent and Include in Match Blank)
    - Click Save
 
 
### Create Local Account Discovery Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields with the information from the application registration
    - Name: ( example Workday Account Scanner)
    - Description: (Enter something meaningful to your Organization)
    - Active: (Checked)
    - Script Type: Powershell
    - Category: Discovery Scanner
    - Merge Fields: Leave Blank
    - Script: Copy and paste the Script included in the file [Workday-Discovery](./Workday-Discovery.ps1)
    - Click Save
  

### Create Workday Tenant Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** > Workday Tenant Scanner 
        - **Description:** (Example - Base scanner used to discover Workday)
        - **Discovery Type:**  Host
        - **Base Scanner:**  Manual Input Discovery
        - **Input Template**: Discovery Source
        - **Output Template:**: Workday Tenant (Use Template that Was Created in the [Workday Scan Template Section](#create-workday-tenant-scan-template))
    - Click Save
   
### Create Workday Account Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** (Example - Workday Account Scanner) 
        - **Description:** (Example - Discovers Workday accounts according to configured privileged account template )
        - **Discovery Type:**  Accounts
        - **Base Scanner:** PowerShell Discovery Create Discovery Script
        - **Allow OU Input**: Yes
        - **Input Template**: Workday Tenant (Use Template that Was Created in the [Workday Tenant Scan Template Section](#create-workday-tenant-scan-template))
        - **Output Template:**: Workday Account  (Use Template that Was Created in the [Create Workday Account Scan Template Section](#create-workday-account-scan-template))
        - **Script:** Workday Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-local-account-discovery-script))
        - **Script Arguments:**
        ```PowerShell
        $[1]$Admin-Groups $[1]$ClientId $[1]$username $[1]$raas-endpoint $[1]$token-url $[1]$$pk
        ```
    - Click Save
  

### Create Discovery Source

- Navigate to **Admin | Discovery | Discovery Sources**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
    - **Name:** (example: Workday Test Tenant)
    - **Site** (Select Site Where Discovery will run)
    - **Source Type** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click **Add Scanner**
- Find the Workday Tenant Scanner or the Scanner Created in the [Create Workday Tenant Scanner Section](#create-workday-tenant-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- In the **lines Parse Format** Section Enter the Source Name (example: Workday Tenant)
- Click **Save**

- Click **Add Scanner**
- Find the Workday Account Scanner  or the Scanner Created in the [Create Workday Account Scanner Section](#create-workday-account-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- Click **Edit Scanner**
- Click the **Add Secret** Link
- Search for the Privileged Account Secret created in the [Overview.md file](../Overview.md)
- Check the Use Site Run As Secret Check box to enable it
    **Note Default Site run as Secret had to ne setup in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box



## Optional Report

In this section, There are instructions on creating an optional report to display user information found in the discovery.


- Login to Secret Server Tenant (If you have not already done so)
- Navigate to the Reports module
- click on the New Report Button
- Fill in the following values:

- Name: The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section

- Description: (Enter something meaningful to your organization)

- Category: Select the Section where you would like the report to appear (ex. Discovery Scan)

- Report SQL: Copy and Paste the SQL Query below

***Note** " You must replace the WHERE d.DiscoverySourceId = 32 value with the Discovery Source ID of the Discovery source you are reporting on. You can find this by opening up the Discovery source and finding the ID in the URL

  

``` SQL

  

SELECT

  

d.[ComputerAccountId]

  

,d.[CreatedDate]

  

,d.[AccountName] AS [Username]

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Tenant-url'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Domain]

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Admin-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Admin]

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Service-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Service Acount]

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Local-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Service Acount]

  

FROM tbComputerAccount AS d

  

CROSS  APPLY  OPENJSON (d.AdditionalData) AS adata

  

INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = d.ScanItemTemplateId

  

WHERE d.DiscoverySourceId =  32

  

GROUP BY d.ComputerAccountId, d.AccountName, d.CreatedDate

  

  

```

- Click Save

  

You will now find this report under the section you chose in the Category field.

### Next Steps

 The Workday configuration is now complete.  The next step is to run a manual discovery scan.
- Navigate to  **Admin | Discovery**
- Click the **Run Discovery Now** (Dropdown) and select **Run Discovery Now**
- Click on the **Network view** Button in the upper right corner
- Click on the newly created discovery source
- Click the **Domain \ Cloud Accounts** tab to view the discovered accounts