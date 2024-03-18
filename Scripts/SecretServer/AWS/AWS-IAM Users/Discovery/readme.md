# AWS IAM User Discovery


## Create Discovery Source

  

This scanner will scan AWS for administrative accounts.

  

### Create AWS Tenant Scan Template

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: AWS Tenant)

-  **Active:** (Checked)

-  **Scan Type:** Host

-  **Parent Scan Template:** Host Range

-  **Fields** Change HostRange to **tenant-url**

- Click Save

### Create Account Scan Template

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: AWS IAM User)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

	- Change Resource to **tenant-url**

	- Add field: Admin-Account (Leave Parent and Include in Match Blank)

	- Add field: Service-Account (Leave Parent and Include in Match Blank)

	- Add field: Local-Account (Leave Parent and Include in Match Blank)

- Click Save

### Create Discovery Script

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to**ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

	- **Name:** (example: -AWS IAM User Scanner)

	- **Description:** (Enter something meaningful to your Organization)

	- **Active:** (Checked)

	- **Script Type:** PowerShell

	- **Category:** Discovery Scanner

	- **Merge Fields:** Leave Blank

	- **Script:** Copy and paste the Script included in the file [AWS IAM User Discovery.ps1](./AWS%20IAM%20User%20Discovery.ps1)

- Click Save


### Create AWS Tenant Scanner

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields:

	- **Name:** > AWS Tenant Scanner

	- **Description:** (Example - Base scanner used to discover AWS Tenant)

	- **Discovery Type:** Host

	- **Base Scanner:** Host

	- **Input Template:** Manual Input Discovery

	- **Output Template:** AWS Tenant (Use the Template that Was created in the [AWS Tenant Scan Template Section](#create-aws-tenant-scan-template)

- Click Save

### Create AWS IAM User Scanner

- Log in to Secret Server Tenant (If you have not already done so) 

- Navigate to **Admin** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields:

	- **Name:** (Example: AWS IAM User Scanner)

	- **Description:** (Example - Discovers AWS IAM Users according to configured privileged account template )

	- **Discovery Type:** Account

	- **Base Scanner:** PowerShell Discovery

	- **Input Template:** AWS Tenant (Use the Template that Was Created in the [AWS Tenant Scan Template Section](#create-aws-tenant-scan-template))

	- **Output Template:**: AWS IAM User (Use the Template that Was Created in the [AWS IAM User Scan Template Section](#create-account-scan-template))

	- **Script:** AWS Local Account Scanner (Use the Script Created in the [Create Discovery Script Section](#create-discovery-script))

	- **Script Arguments:**

	``` PowerShell

	"IAMUser-Advanced" $[1]$AccessKey $[1]$SecretKey $[1]$Admin-Criteria $[1]$SVC-Account-Criteria

	```

- Click Save

### Create Discovery Source

- Navigate to **Admin | Discovery | Configuration**

- Click **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below

- **Name:** (example: AWS Tenant)

- **Site** (Select Site Where Discovery will run)

- **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the AWS Tenant Scanner or the Scanner created in the [Create AWS Tenant Scanner Section](#create-aws-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just completed and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: AWS Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the AWS Local Account Scanner or the Scanner created in the [Create SWS IAM User Scanner Section](#create-aws-iam-user-scanner) and Click **Add Scanner**

- Select the Scanner just completed and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the AWS Service Account Secret created in the [instructions.md file](../Instructions.md)

- Check the Use Site Run-As Secret Check box to enable it

**Note Default Site run as Secret has to be set up in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and click the Active check box

- Click Save  
  

## Optional Report

In this section, there are instructions on creating an optional report to display user information found in the discovery.


- Login to Secret Server Tenant (if you have not already done so)
- Navigate to the Reports module
- Click on the New Report Button
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
,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'Tenant-url'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [tenant-url]
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

  

The AWS  configuration is now complete. The next step is to run a manual discovery scan and view your discovered accounts in the **Admin | Discovery | Network View ** Panel
