# Okta Local Account Discovery

## Create Discovery Source

This scanner will perform a Discovery of Okta Users.

### Create Okta Tenant Scan Template

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**
- Click **Create Scan Template**
- Fill out the required fields with the information:
  - **Name:** (Example: Okta Tenant)
  - **Active:** (Checked)
  - **Scan Type:** Host
  - **Parent Scan Template:** Host Range
  - **Fields** Change HostRange to **tenant-url**
- Click Save


  

  

### Create Account Scan Template

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**
- Click **Create Scan Template**
- Fill out the required fields with the information:
  - **Name:** (Example: Okta User)
  - **Active:** (Checked)
  -  *Scan Type:** Account
  - **Parent Scan Template:** Account(Basic)
  - **Fields**
    - Change Resource to **tenant-url**
    - Add field: Admin-Account (Leave Parent and Include in Match Blank)
    - Add field: Service-Account (Leave Parent and Include in Match Blank)
    - Add field: Local-Account (Leave Parent and Include in Match Blank)
- Click Save

  


### Create Discovery Script

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to**Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields with the information from the application registration
  - **Name:** ( example - Okta Account Scanner)
  - **Description:** (Enter something meaningful to your Organization)
  - **Active:** (Checked)
  - **Script Type:** Powershell
  - **Category:** Discovery Scanner
  - **Merge Fields:**Leave Blank
  - **Script:** Copy and paste the Script included in the file [Okta Account Discovery](./Okta%20Account%20Discovery.ps1)
- Replace the script value for $rateLimit to 3 less than your organizations rate limit for /api/v1/users*  
- Click Save

### Create Saas Tenant Scanner
- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** >
- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
- Click **Create Scanner**
- Fill out the required fields:
  - **Name:** > Okta Tenant Scanner
  - **Active** - Checked
  - **Description:** (Example - Base scanner used to discover Okta Tenant)
  - **Discovery Type:** Host
  - **Base Scanner:** Manual Input Discovery
  - **Input Template**: Discovery Source
  - **Output Template:**: Okta Tenant (Use Template that Was created in the [Okta Scan Template Section](#create-okta-tenant-scan-template))
- Click Save

### Create Okta Local Account Scanner

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** >
- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
- Click **Create Scanner**
- Fill out the required fields:
  - **Name:** (Example - Okta Local Account Scanner)
  - **Description:** (Example - Discovers Okta local accounts according to configured privileged account template )
  - **Active** - Checked
  - **Discovery Type:** Account
  - **Base Scanner:** PowerShell Discovery 
  - **Allow OU Input** - Checked
  - **Input Template**: Okta Tenant (Use Template that Was Created in the [Okta Scan Template Section](#create-okta-tenant-scan-template))
  - **Output Template:**: Okta User (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))
-  **Script:** Okta Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
  - **Script Arguments: 
  ``` powershell
  $[1]$Tenant-url $[1]$client-id $[1]$Key-ID  $[1]$Private-Key $[1]$Service-Account-Attributes $[1]$Admin-Roles

  ```
- Click Save

### Create Discovery Source

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin | Discovery | Configuration**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
  - **Name:** (example: Okta Test Tenant)  
  - **Site** (Select Site Where Discovery will run)
  - **Source Type** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click **Add Scanner**
- Find the Okta Tenant Scanner or the Scanner Created in the [Create Okta Tenant Scanner](#create-saas-tenant-scanner)
- Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- In the **lines Parse Format** Section Enter the Source Name (example: Okta Tenant)
- Click **Save**
- Click **Add Scanner**
- Find the Okta Local Account Scanner or the Scanner Created in the [Create Okta Local Account Scanner ](#create-okta-local-account-scanner) Section 
- Click **Add Scanner**
- Select the Scanner just Created
- Click **Edit Scanner**
- Click the **Add Secret** Link
- Search for the PrivIleged Account Secret created in the [Overview Document](../instructions.md#create-secret-in-secret-server-for-the-okta-privileged-account)
- Check the Use Site Run As Secret Check box to enable it

  **Note Default Site run as Secret had to have been setup in the Site configuration.

  See the Setting the Default PowerShell Credential for a Site section in the Delinea Document found [here](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site)
- Click Save
- Click on the **Discovery Source** tab and Click the **Active** check box


### Next Steps

The Okta configuration is now complete. The next step is to run a manual discovery scan.
- Navigate to **Admin | Discovery**
- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**
- Click on the **Network view** Button in the upper right corner
- Click on the newly created discovery source
- Click the **Domain \ Cloud Accounts** tab to view the discovered accounts
  

## Optional Report

In this section, There are instructions on creating an optional report to display user information found in the discovery.

- Login to Secret Server Tenant (If you have not already done so)

- Navigate to the Reports module

- Click on the **New Report** Button
- Fill in the following values:
  - **Name:** The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section
  - **Description:** (Enter something meaningful to your organization)
  - **Category:** Select the Section where you would like the report to appear (ex. Discovery Scan)
  - **Report SQL:** Copy and Paste the SQL Query below

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