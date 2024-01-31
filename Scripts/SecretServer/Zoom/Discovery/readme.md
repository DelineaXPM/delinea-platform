# Zoom Account Discovery

  

## Create Discovery Source

  

### Create Zoom Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Zoom Tenant)

-  **Active:** (Checked)

-  **Scan Type:** Host

-  **Parent Scan Template:** Host Range

-  **Fields**

- Change HostRange to **tenant-url**

- Click Save

- This completes the creation of the Zoom Scan Template Creation

  

### Create Zoom Account Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Zoom Account)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

- Change Resource to **tenant-url**

- Add field: Local-Account (Leave Parent and Include in Match Blank)

- Add field: Admin-Account (Leave Parent and Include in Match Blank)

- Add field: Service-Account (Leave parent and Include in Match Blank)

- Click Save

- This completes the creation of the Zoom Account Scan Template Creation

### Create Local Account Discovery Script

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

- Name: ( example Zoom Account Scanner)

- Description: (Enter something meaningful to your Organization)

- Active: (Checked)

- Script Type: Powershell

- Category: Discovery Scanner

- Merge Fields: Leave Blank

- Script: Copy and paste the Script included in the file [Zoom Discovery.ps1](./Zoom%20Discovery.ps1)

- Click Save

- This completes the creation of the Local Account Discovery Script

  

### Create Zoom Tenant Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** > Zoom Tenant Scanner

-  **Description:** (Example - Base scanner used to discover Zoom)

-  **Discovery Type:** Host

-  **Base Scanner:** Manual Input Discovery

-  **Input Template**: Discovery Source

-  **Output Template:**: Zoom Tenant (Use Template that Was Created in the [Zoom Scan Template Section](#create-Zoom-scan-template))

- Click Save

- This completes the creation of the Zoom Tenant Scanner

  

### Create Zoom Account Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** (Example - Zoom Account Scanner)

-  **Description:** (Example - Discovers Zoom accounts according to configured privileged account template )

-  **Discovery Type:** Accounts

-  **Base Scanner:** PowerShell Discovery Create Discovery Script

-  **Allow OU Input**: Yes

-  **Input Template**: Zoom Tenant (Use Template that Was Created in the [Zoom Scan Template Section](#Zoom-scan-template))

-  **Output Template:**: Zoom Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))

-  **Script:** Zoom Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

-  **Script Arguments:**

```PowerShell

$[1]$discovery-mode $[1]$tenant-url $[1]$account-id $[1]$client-id $[1]$client-secret $[1]$federation-domains $[1]$service-account-groups

```

- Click Save

- This completes the creation of the Zoom Account Scanner

  

### Create Discovery Source

  

- Navigate to **Admin | Discovery | Discovery Sources**

- Click **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below

- **Name:** (example: Zoom Test Tenant)

- **Site** (Select Site Where Discovery will run)

- **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the Saas Tenant Scanner or the Scanner Created in the [Create Zoom Tenant Scanner Section](#create-Zoom-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: Zoom Test Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the Zoom Account Scanner or the Scanner Created in the [Create Zoom Account Scanner Section](#create-Zoom-account-såcanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privileged Account Secret created in the [Overview.md file](../Overview.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- This completes the creation of the Discovery Source

  

## Optional Report

  

  

In this section, There are instructions on creating an optional report to display user information found in the discovery.

  

  

- Login to Secret Server Tenant (If you have not already done so)

- Navigate to the Reports module

- click on the New Report Button

- Fill in the following values:

- Name: The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section (ex. MyDiscoverySource - Discovery )

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

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Service-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Service Account]

  

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Local-Account'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Is Service Account]

  

FROM tbComputerAccount AS d

  

CROSS  APPLY  OPENJSON (d.AdditionalData) AS adata

  

INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = d.ScanItemTemplateId

  

WHERE d.DiscoverySourceId =  32

  

GROUP BY d.ComputerAccountId, d.AccountName, d.CreatedDate

  

  

```

- Click Save

  

You will now find this report under the section you chose in the Category field.

  

### Next Steps

  

The Zoom configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Now** (Dropdown) and select **Run Discovery Now**

- Click on the **Network view** Button in the upper right corner

- Click on the newly created discovery source

- Click the **Domain \ Cloud Accounts** tab to view the discovered accounts