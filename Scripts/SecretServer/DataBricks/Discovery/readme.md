# Delinea Secret Server / EntraID/Azure Databricks Integration Base configuration

 
This connector provides the following functions



- Discovery of Local Accounts


- Remote Password Changing of Local Users


- Heartbeats of Local Accounts to verify that user credentials are still valid

  

Follow the Steps below to complete the base setup for this integration. These steps are required to run any of the processes.

  


The following steps are required to create the Secret Template for Databricks Advanced Users: 
  

### Create Databricks Tenant Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

  -  **Name:** (Example: Databricks Tenant)

  -  **Active:** (Checked)

  -  **Scan Type:** Host

  -  **Parent Scan Template:** Host Range

  -  **Fields**

  - Change HostRange to **tenant-url**

- Click Save

- This completes the creation of the Databricks Scan Template Creation

  
  
  

### Create Databricks Account Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

  -  **Name:** (Example: Databricks Account)

  -  **Active:** (Checked)

  -  **Scan Type:** Account

  -  **Parent Scan Template:** Account(Basic)

  -  **Fields**

  - Change Resource to **tenant-url**

  - Add field: Admin-Account (Leave Parent and Include in Match Blank)

  - Add field: Service-Account (Leave Parent and Include in Match Blank)

  - Add field: Local-Admin (Leave Parent and Include in Match Blank)


- Click Save

- This completes the creation of the Account Scan Template Creation

  

Follow the Steps below to complete the base setup for this integration. These steps are required to run any of the processes.


The following steps are required to create the Secret Template for Databricks Advanced Users:

- Log in to the Delinea Secret Server (If you have not already done so)

- Navigate to Admin / Secret Templates

- Click on Create / Import Template

- Click on Import.

- Copy and Paste the XML in the [Databricks User Advanced File](./templates/Databricks%20User%20Advanced.xml)

- Click on Save

- This completes the creation of the User Account template

  

  

  
  
  

  
  
  

  

- Log in to the Delinea Secret Server

  

  

- Navigate to Admin / Secret Templates

  

  

- Click on Create / Import Template

  

  

- Copy and Paste the XML in the [Databricks Privileged Account.xml File](./templates/Databricks%20Privileged%20Account.xml)

  

  

- Click on Save

  

  

- This completes the creation of the secret template

  

  

  
  
  

  

- Log in to the Delinea Secret Server

  

  

- Navigate to Secrets

  

  

- Click on Create Secret

  

  

- Select the template created in the earlier step [Creating Secret Template for Privileged Account](#creating-secret-template-for-databricks-privileged-accounts) (in the example EntraID Application Identity)

  

  

- Fill out the required fields with the information from the application registration

  

  

- Secret Name (for example Databricks Privileged Account)

  

  

- Tenant-URL (The URL of your Azure Databricks workspace.)

  

  

- Client ID: Your Entra ID AD application's Client ID.

  

  

- Client Secret: Your DataBricks Oauth2 secret that was mapped to the EntraID app.

  

  

- Admin-Criteria - These are the Groups that will be used to identify an admin user in Databricks. These groups need to be comma separated of the Group Name.

  

  

Examples:

  

  

- admins

  

  

- admins,samplegroup

  

  

- SVC-Account-Criteria - These are the Groups that will be used to identify a Service Accounts

These groups need to be Comma separated group names.

  
  

Examples:

  
  

- ServiceAccounts1

  
  

- ServiceAccounts1,ServiceAccounts2

  

  

- Click Create Secret Account)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

- Change Resource to **tenant-url**

- Add field: Account-Admin (Leave Parent and Include in Match Blank)

- Add field: Service-Account (Leave Parent and Include in Match Blank)

- Add field: Service-Account (Leave Parent and Include in Match Blank)

- Add field: Local-Account (Leave parent and Include in Match Blank)

- Click Save

- This completes the creation of the Account Scan Template Creation

### Create Discovery Script

  

- Log in to Secret Server Tenant

- Navigate to**ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

- Name: ( example Databricks Account Scanner)

- Description: (Enter something meaningful to your Organization)

- Active: (Checked)

- Script Type: Powershell

- Category: Discovery Scanner

- Merge Fields: Leave Blank

- Script: Copy and paste the Script included in the file Databricks Discovery.ps1](./DataBricks-Account-Discovery.ps1)

- Click Save

- This completes the creation of the Local Account Discovery Script

  

### Create Databricks Tenant Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** > Databricks Tenant Scanner

-  **Description:** (Example - Base scanner used to discover Databricks Accounts)

-  **Discovery Type:** Host

-  **Base Scanner:** Manual Input Discovery

-  **Input Template**: Discovery Source

-  **Output Template:**: Adobe Sign Tenant (Use Template that Was Created in the [Databricks Tenant Scan Template Section](#create-databricks-tenant-scan-template))

- Click Save

- This completes the creation of the Adobe Sign Tenant Scanner

  

### Create Databricks Account Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** (Example - Databricks Account Scanner)

-  **Description:** (Example - Discovers Databricks accounts according to configured privileged account template )

-  **Discovery Type:** Accounts

-  **Base Scanner:** PowerShell Discovery Create Discovery Script

-  **Allow OU Import**: Yes

-  **Input Template**: Databricks Tenant (Use Template that Was Created in the [Databricks Tenant Scan Template Section](#create-databricks-tenant-scan-template))

-  **Output Template:**: Databricks Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-databricks-account-scan-template))

-  **Script:** Databricks Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

  

-  **Script Arguments:**

```PowerShell

$[1] $[1]$tenant-url $[1]$client-Id $[1]$client-Secret $[1]$admin-criteria $[1]$svc-account-criteria $[1]$domain-acct-criteria

```

- Click Save

- This completes the creation of the Databricks Account Scanner

  

### Create Discovery Source

  

- Navigate to **Admin | Discovery | Discovery Sources**

- Click **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below

- **Name:** (example: Databricks Tenant)

- **Site** (Select Site Where Discovery will run)

- **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the Saas Tenant Scanner or the Scanner Created in the [Create Adobe Sign Tenant Scanner Section](#) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: Databricks Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the Databricks Account Scanner or the Scanner Created in the [Create Databricks Account Scanner Section](#create-databricks-account-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privileged Account Secret created in the [instructions.md file](../Instructions.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- This completes the creation of theDiscovery Source

  
  

### Next Steps

  



- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**

- Click on the **Network view** Button in the upper right corner

- Click on the newly created discovery source

- Click the **Domain \ Cloud Accounts** Tab to view the discovered accounts


## Optional Report

  

In this section, There are instructions on creating an optional report to display user information found in the discovery.

  

- Login to Secret Server Tenant (If you have not already done so)

- Navigate to the Reports module
- click on the New Report Button
- Fill in the following values:
	- Name: The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section
	- Description: (Enter something meaningful to your organization)
	- Category: Select the Section where you would like the report to appear (ex. Discovery Scan)
	- Report SQL: Copy and Paste the SQL Query  below
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