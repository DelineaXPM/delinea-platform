# Github Admin and Service Account Discovery

## Create Discovery Source

This scanner can help perform an Scan for user accounts within a Github Organization. Account types will be distinguished by the appropriate roles and Teams designated by Github and Integrations Key Secret.

### Create Github Tenant Scan Template

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: Github Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields** Change HostRange to Organization
- Click Save
 

### Create Github Account Scan Template

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: Github User Account)
    - **Active:** (Checked)
    - **Scan Type:** Account
    - **Parent Scan Template:** Account(Basic)
    - **Fields**
        - Change Resource to **Organization**
        - Add field: Admin-Account (Leave Parent and Include in Match Blank)
        - Add field: Service-Account (Leave Parent and Include in Match Blank)
        - Add field: Local-Account (Leave Parent and Include in Match Blank)
- Click Save
    
 
### Create Discovery Script

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to**Admin** > **Scripts**
- Click on **Create Script**
- Fill out the required fields:
    - **Name:** ( example -Github User Account Scanner)
    - **Description:** (Enter something meaningful to your Organization)
    - **Active:** (Checked)
    - **Script Type:** Powershell
    - **Category:** Discovery Scanner
    - **Merge Fields:** Leave Blank
    - **Script:** Copy and paste the Script included in the file [Github Discovery](./GitHub-Discovery.ps1)
- ~Click Save

### Create Github Tenant Scanner

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click the **Scanners** tab 

- Click **Create Scanner**

- Fill out the required fields:
    - **Name:** > Github Tenant Scanner 
    - **Description:** (Example - Base scanner used to discover Github Organization)
    - **Discovery Type:**  Host
    - **Base Scanner:**  Host
    - **Input Template**: Manual Input Discovery
    - **Output Template:**: Github Tenant (Use Template that Was Created in the [Create Github  Scan Template Section](#create-github-tenant-scan-template))
- Click Save
    
### Create Github Account Scanner

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click the **Scanners** tab 

- Click **Create Scanner**
- Fill out the required fields with the information
    - **Name:** (Example - GitHub User Account Scanner) 
    - **Description:** (Example - Discovers Github User accounts according to the configured Github Integration Key TSecret )
    - **Discovery Type:**  Account
    - **Base Scanner:** PowerShell Discovery
    - **Input Template**: Github Tenant (Use Template that Was Created in the [Github Tenant Scan Template Section](#create-github-tenant-scan-template))
    - **Output Template:**: Github Account  (Use Template that Was Created in the [Create Github Account Scan Template Section](#create-github-account-scan-template))
    - **Script:** GitHub User Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
    - **Script Arguments: 
        ``` PowerShell
        $[1]$Advanced $[1]$OAuthToken $[1]$admin-roles $[1]$svcacct-roles 
        ```
- Click Save
       
### Create Discovery Source

- Log in to Secret Server Tenant (If you have not already done so)
- Navigate to **Admin | Discovery | Configuration**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
    - **Name:** (example: Github Tenant [Workspace Name])
    - **Site** (Select Site where Discovery will run)
    - **Source Type** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click **Add Scanner**
- Find the Github Tenant Scanner or the Scanner Created in the [Create Github Tenant Scanner Section](#create-github-tenant-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- In the **lines Parse Format** Section Enter the Source Name (example: Github Tenant)
- Click **Save**

- Click **Add Scanner**
- Find the Github User Account Scanner  or the Scanner Created in the [Github Github User Account Scanner Section](#create-github-account-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- Click **Edit Scanner**
- Click the **Add Secret** Link
- Search for the Integration Key Secret created in the [Instructions file](../instructions.md#create-secret-in-secret-server-for-the-github-integration-key)
- Check the Use Site Run As Secret Check box to enable it
    **Note Default Site run as Secret had to ne setup in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box
-Click Save

## Optional Report

  

In this section, There are instructions on creating an optional report to display user information found in the discovery.

  

- Login to Secret Server Tenant (If you have not already done so)
- Navigate to the Reports module
- click on the New Report Button
- Fill in the following values:
	- **Name:** The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section (ex. MyDiscoverySource - Discovery )
	- **Description:** (Enter something meaningful to your organization)
	- **Category:** Select the Section where you would like the report to appear (ex. Discovery Scan)
	- **Report SQL:** Copy and Paste the SQL Query below
		***Note** " You must replace the WHERE d.DiscoverySourceId =  32 value with the Discovery Source ID of the Discovery source you are reporting on. You can find this by opening up the Discovery source and finding the ID in the URL 
   

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

The Github configuration is now complete. The next step is to run a manual discovery scan and view your discovered accounts in the **Admin | Discovery | Network View ** Panel
