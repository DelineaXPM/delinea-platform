
# Salesforce User Discovery

  

## Create Discovery Source

  

This scanner can help perform an Scan for Windows Systems based off an IP address range.

  

### Create Salesforce Tenant Scan Template

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

- **Name:** (Example: Salesforce Tenant)

- **Active:** (Checked)

- **Scan Type:** Host

- **Parent Scan Template:** Host Range

- **Fields:** Change HostRange to **tenant-url**

- Click Save

### Create Account Scan Template

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Salesforce User)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

    - Change Resource to tenant-url

    - Add field: Admin-Account (Leave Parent and Include in Match Blank)

    - Add field: Service-Account (Leave Parent and Include in Match Blank)

    - Add field: Local-Account (Leave Parent and Include in Match Blank)

- Click Save


### Create Discovery Script

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to**Admin    ** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

    - **Name:** ( example -Salesforce User Scanner)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Discovery Scanner

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [Salesforce User Discovery](./Salesforce%20Locaal%20Account%20Discovery.ps1)

- Click Save
  

### Create Salesforce Tenant Scanner

  
  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

    - **Name:** Salesforce Tenant Scanner

    - **Description:** (Example - Base scanner used to discover Salesforce Tenants)

    - **Discovery Type:** Host

    -  \**Base Scanner:** Host

    - **Input Template**: Manual Input Discovery

    - **Output Template:**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Scan Template Section](#create-salesforce-tenant-scan-template)

- Click Save

  

### Create Salesforce User Scanner

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

    - **Name:** (Example - Salesforce User Scanner)

    - **Description:** (Example - Discovers Salesforce Users according to configured privileged account template )

    - **Discovery Type:** Account

    - **Base Scanner:** PowerShell Discovery Create Discovery Script

    - **Input Template**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Tenant Scan Template Section](#create-salesforce-tenant-scan-template))

    - **Output Template:**: Salesforce User (Use Template that Was Created in the [Salesforce User Scan Template Section](#create-account-scan-template))

    - **Script:** Salesforce Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

    - **Script Arguments:**

    ``` powershell

        $[1]$SFDC-URL $[1]$client-id $[1]$client-secret $[1]$Admin-Criteria $[1]$Service-Account-Criteria $[1]$Domain-Acct-Criteria

    ```

- Click Save



### Create Discovery Source

  

- Navigate to **Admin | Discovery | Configuration**

- Click **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below

    - **Name:** (example: Salesforce Tenant)

    - **Site** (Select Site Where Discovery will run)

    - **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the Salesforce Tenant Scanner or the Scanner Created in the [Create Salesforce Tenant Scanner Section](#create-salesforcetenant-scanner)) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: Salesforce Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the Salesforce Local Account Scanner or the Scanner Created in the [Create Salesforce User Scanner Section](#create-salesforce-user-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Salesforce Service Account Secret created in the [instructions file](../Instructions.md#create-secret-in-secret-server-for-the-salesforce-privileged-account)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the **Active** check box

## Optional Report

In this section, There are instructions on creating an optional report to display user information found in the discovery.


- Login to Secret Server Tenant (If you have not already done so)
- Navigate to the Reports module
- click on the New Report Button
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

  

The Salesforce configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**

- Click on **Network view**

- Find the newly created discovery source and Users
  

  
