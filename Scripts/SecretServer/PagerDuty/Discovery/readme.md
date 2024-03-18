# PagerDuty Account Discovery

## Create Discovery Source

### Create PagerDuty Scan Template

- Log in to Secret Server Tenant (if not already logged in)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click **Create Scan Template**

- Fill out the required fields with the information
    - **Name:** (example: PagerDuty Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields** Change HostRange to **tenant-url**
- Click Save

### Create PagerDuty Account Scan Template

- Log in to Secret Server Tenant  (if not already logged in)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click **Create Scan Template**

- Click **Create Scan Template**

- Fill out the required fields with the information
    - **Name:** (Example: PagerDuty Account)
    - **Active:** (Checked)
    - **Scan Type:** Account
    - **Parent Scan Template:** Account(Basic)
    - **Fields**
        - Change Resource to **tenant-url**
        - Add field: Local-Account (Leave Parent and Include in Match Blank)
        - Add field: Admin-Account (Leave Parent and Include in Match Blank)
        - Add field: Service-Account (Leave parent and Include in Match Blank)
    - Click Save
 
### Create Local Account Discovery Script

- Log in to Secret Server Tenant  (if not already logged in)

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration
    - **Name:** (example: PagerDuty Account Scanner)
    - **Description:** (Enter something meaningful to your Organization)
    - **Active:** (Checked)
    - **Script Type:** Powershell
    - **Category:** Discovery Scanner
    - **Merge Fields:** (Leave Blank)
    - **Script:** Copy and paste the Script included in the file [PagerDuty Discovery](./PagerDuty%20Discovery.ps1)
- Click Save

### Create PagerDuty Tenant Scanner

- Log in to Secret Server Tenant  (if not already logged in)

- Navigate to **Admin** > **Discovery**

- Click on the **Configuration** tab

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scanner** tabs 

- Click **Create Scanner**

- Fill out the required fields:
    - **Name:** > PagerDuty Tenant Scanner 
    - **Description:** (Example - Base scanner used to discover PagerDuty)
    - **Discovery Type:**  Host
    - **Base Scanner:**  Manual Input Discovery
    - **Input Template**: Discovery Source
    - **Output Template:**: PagerDuty Tenant (Use Template that Was Created in the [PagerDuty Scan Template Section](#create-PagerDuty-scan-template))
- Click Save
 
### Create PagerDuty Account Scanner

- Log in to Secret Server Tenant  (if not already logged in)

- Navigate to **Admin** > **Discovery**

- Click on the **Configuration** tab

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scanner** tabs 

- Click **Create Scanner**

- Fill out the required fields with the information
    - **Name:** (Example - PagerDuty Account Scanner) 
    - **Description:** (Example - Discovers PagerDuty accounts according to configured privileged account template )
    - **Discovery Type:**  Accounts
    - **Base Scanner:** PowerShell Discovery Create Discovery Script
    - **Allow OU Inpurt**: Yes
    - **Input Template**: PagerDuty Tenant (Use Template that Was Created in the [PagerDuty Scan Template Section](#pagerduty-scan-template))
    - **Output Template:**: PagerDuty Account  (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))
    - **Script:** PagerDuty Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
    
    - **Script Arguments:**
    ```PowerShell
    $[1]$discovery-mode $[1]$tenant-url $[1]$integration-token $[1]$saml-enabled $[1]$service-account-groups
    ```
- Click Save
      
### Create Discovery Source

- Navigate to **Admin | Discovery | Discovery Sources**

- Click the **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below
    - **Name:** (example: PagerDuty Tenant)
    - **Site:** (Select Site Where Discovery will run)
    - **Source Type:** Empty
- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the Saas Tenant Scanner or the Scanner Created in the [Create PagerDuty Tenant Scanner Section](#create-pagerduty-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: PagerDuty Test Tenant)

- Click **Save**

- Click **Add Scanner**

- Find the PagerDuty Account Scanner  or the Scanner Created in the [Create PagerDuty Account Scanner Section](#create-pagerduty-account-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privileged Account Secret created in the [Overview.md file](../Overview.md)

- Check the Use Site Run As Secret Check box to enable it
    **Note Default Site run as Secret had to ne setup in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- Click Save

## Optional Report


In this section, there are instructions on creating an optional report to display user information found in the discovery.

  

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

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Tenant-url'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Tenant]

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Admin-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Admin Account]

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Service-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Service Account]

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Local-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Local Account]

FROM tbComputerAccount AS d

CROSS  APPLY  OPENJSON (d.AdditionalData) AS adata

INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = d.ScanItemTemplateId

WHERE d.DiscoverySourceId =  32

GROUP BY d.ComputerAccountId, d.AccountName, d.CreatedDate
  
```

- Click Save

You will now find this report under the section you chose in the Category field.



### Next Steps

The PagerDuty configuration is now complete.  The next step is to run a manual discovery scan.

- Navigate to  **Admin | Discovery**

- Click the **Run Discovery Now** Dropdown List

- Select **Run Discovery Scan**

- Click on the **Network view** to view the discovered accounts


