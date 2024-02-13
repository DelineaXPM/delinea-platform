# FiveTran Account Discovery

  

## Create Discovery Source

  

This scanner will perform a scan for FiveTran User accounts .

  

## Create FiveTran Scan Templates

  

### Create Tenant Scan Template

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

  -  **Name:** (Example: FiveTran Tenant)

  -  **Active:** (Checked)

  -  **Scan Type:** Host

  -  **Parent Scan Template:** Host Range

  -  **Fields:** Change HostRange to **tenant-url**

- Click Save

- This completes the creation of the FiveTran Scan Template Creation

  

### Create Account Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

  -  **Name:** (Example: FiveTran Account)

  -  **Active:** (Checked)

  -  **Scan Type:** Account

  -  **Parent Scan Template:** Account(Basic)

  -  **Fields:** Change Resource to **tenant-url**

  - Add field: Admin-Account (Leave Parent and Include in Match Blank)

  - Add field: Service-Account (Leave Parent and Include in Match Blank)

  - Add field: Local-Account (Leave Parent and Include in Match Blank)

- Click Save

- This completes the creation of the Account Scan Template Creation

### Create Discovery Script

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

  - **Name:** ( example - FiveTran Account Scanner)

  - **Description:** (Enter something meaningful to your Organization)

  - **Active:** (Checked)

  - **Script Type:** Powershell

  - **Category:** Discovery Scanner

  - **Merge Fields:** Leave Blank

  - **Script:** Copy and paste the Script included in the file [FiveTran Account Discovery](./FiveTran%20Account%20Discovery.ps1)

- Click Save

- This completes the creation of the FiveTran Account Discovery Script

  

### Create FiveTran Tenant Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

  -  **Name:** FiveTran Tenant Scanner

  -  **Description:** (Example - Base Scanner used to discover FiveTran application)

  -  **Discovery Type:** Host

  -  **Base Scanner:** Manual Input Discovery

  -  **Input Template:**: Discovery Source

  -  **Output Template:**: FiveTran Tenant (Use Template that Was Created in the [FiveTran Scan Template Section](#create-tenant-scan-template))

- Click Save

- This completes the creation of the FiveTran Tenant Scanner

  

### Create FiveTran Account Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

  -  **Name:** (Example - FiveTran Account Scanner)

  -  **Description:** (Example - Discovers FiveTran accounts according to configured FiveTran Discovery Secret)

  -  **Discovery Type:** Account

  -  **Base Scanner:** PowerShell Discovery Create Discovery Script

  - Allow OU Input Checked

  -  **Input Template**: FiveTran Tenant (Use Template that Was Created in the [FiveTran Scan Template Section](#create-tenant-scan-template))

  -  **Output Template:**: FiveTran Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))

  -  **Script:** FiveTran Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

  - **Script Arguments:**

```powershell

$[1]$Discovery-Mode $[1]$tenant-url $[1]$API-Key $[1]$API-Secret $[1]$Admin-Account-Teams $[1]$Service-Account-Teams $[1]$Federated-Domains

  

```

- Click Save

- This completes the creation of the ServiceNow Account Scanner

  

### Create Discovery Source

  

- Navigate to **Admin | Discovery | Configuration**

- Click **Create** drop-down

- Click **Empty Discovery Source**

- Enter the Values below

  - **Name:** (example: FiveTran Discovery)

  - **Site** (Select Site Where Discovery will run)

  - **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the FiveTran Tenant Scanner or the Scanner Created in the [Create FiveTran Tenant Scanner Section](#create-fivetran-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **Lines Parse Format** Section Enter the Source Name (example: FiveTran  Tenant)

- Click **Save**

- Click **Add Scanner**

- Find the FiveTran Local Account Scanner or the Scanner Created in the [Create FiveTran Account Scanner Section](#create-fivetran-account-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Discovery Account Secret created in the [instructions.md file](../Instructions.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.**

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- This completes the creation of the FiveTran Discovery Source

  
  

### Next Steps

  

The FiveTran configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**

- Click on the **Network view** Button in the upper right corner

- Filter on the newly created discovery source to view the discovered Accounts



## Optional Report

  

In this section, There are instructions on creating an optional report to display user information found in the discovery.

  

- Login to Secret Server Tenant (If you have not already done so)

- Navigate to the Reports module
- Click on the New Report Button
- Fill in the following values:
	- Name: The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section
	- Description: (Enter something meaningful to your organization)
	- Category: Select the Section where you would like the report to appear (ex. Discovery Scan)
	- Report SQL: Copy and Paste the SQL Query  below
		***Note** " You must replace the WHERE d.DiscoverySourceId =  38 value with the Discovery Source ID of the Discovery source you are reporting on. You can find this by opening up the Discovery source and finding the ID in the URL 

    - Example: https://MyTenant.secretservercloud.com/app/#/admin/discovery/source/38/general

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

WHERE d.DiscoverySourceId =  38

GROUP BY d.ComputerAccountId, d.AccountName, d.CreatedDate
```
- Click Save

You will now find this report under the section you chose in the Category field.
