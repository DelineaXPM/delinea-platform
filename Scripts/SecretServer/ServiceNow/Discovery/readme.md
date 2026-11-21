# ServiceNow Account Discovery

This scanner will perform discovery of ServiceNow Accounts.

## Log Files

The discovery script writes to the following log files in the Distributed Engine log folder:

| File | Description |
|------|-------------|
| `ServiceNow-Discovery.log` | Main application log with INFO, WARN, ERROR, and DEBUG messages |
| `ServiceNow-Discovery-Results.json` | JSON file containing discovered accounts |

**Default Location:** `%ProgramFiles%\Thycotic Software Ltd\Distributed Engine\log\`

The log level can be adjusted by modifying the `$LogLevel` variable at the top of the script:
- `0` = INFO only
- `1` = INFO + WARN
- `2` = INFO + WARN + ERROR
- `3` = All messages including DEBUG (default)

## Input Validation

The script validates all input parameters before execution:

| Parameter | Validation |
|-----------|------------|
| DiscoveryMode | Must be "Advanced" or "Default" |
| host | Must start with "https://" |
| All credentials | Checked for unsubstituted placeholder values (e.g., `$username`) |

If validation fails, the script logs an error and terminates before making any API calls.

## Create Discovery Source

  
### Create ServiceNow Tenant Scan Template

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tab

- Click on **Create Scan Template**

- Fill out the required fields:

    - **Name:** (Example: ServiceNow Tenant)

    - **Active:** (Checked)

    - **Scan Type:** Host

    - **Parent Scan Template:** Host Range

    - **Fields:**  Change HostRange to **host**

- Click Save

### Create ServiceNow Account Scan Template

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tab

- Click on **Create Scan Template**

- Fill out the required fields:

    - **Name:** (Example: ServiceNow Account)

    - **Active:** (Checked)

    - **Scan Type:** Account

    - **Parent Scan Template:** Account(Basic)

    - **Fields**

        - Change Resource to **host**

        - Add field: Admin-Account (Leave Parent and Include in Match Blank)

        - Add field: Service-Account (Leave Parent and Include in Match Blank)

        - Add field: Local-Account (Leave Parent and Include in Match Blank)

- Click Save

### Create Discovery Script

  
- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields:

    - **Name:** ( example -ServiceNow Local Account Scanner)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Discovery Scanner

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [ServiceNow Account Discovery](./ServiceNow%20Account%20Discovery.ps1)

- Click Save



### Create ServiceNow Tenant Scanner

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scanners** tab

- Click on **Create Scanner**

- Fill out the required fields:

    - **Name:** ServiceNow Tenant Scanner

    - **Description:** (Example - Base scanner used to discover ServiceNow Tenants)

    - **Discovery Type:** Host

    - **Base Scanner:** Host

    - **Input Template:** Manual Input Discovery

    - **Output Template:** ServiceNow Tenant (Use Template that Was Created in the [ServiceNow Tenant Scan Template Section](#create-servicenow-tenant-scan-template))

- Click Save

### Create ServiceNow Account Scanner

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scanners** tab

- Click on **Create Scanner**

- Fill out the required fields:

    - **Name:** (Example - ServiceNow  Account Scanner)

    - **Description:** (Example - Discovers ServiceNow accounts according to configured privileged account template )

    - **Discovery Type:** Account

    - **Base Scanner:** PowerShell Discovery

    - **Input Template:** Select the ServiceNow Tenant Scan Template that Was Created in the [ServiceNow Tenant Scan Template Section](#create-servicenow-tenant-scan-template)

    - **Output Template:** Select the ServiceNow Account Scan Template (Use Template that Was Created in the [Create Account Scan Template Section](#create-servicenow-account-scan-template))

    - **Script:** ServiceNow Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

    - **Script Arguments:** (Use `Advanced` or `Default` for the first argument)
    ``` powershell
        Advanced $[1]$tenant-url $[1]$username $[1]$password $[1]$client-id $[1]$client-secret $[1]$admin-roles $[1]$svc-groupids $[1]$local-acct-grpids
    ```
- Click Save

#### Discovery Mode Options

| Mode | Description |
|------|-------------|
| **Advanced** | Discovers admin accounts, service accounts, and local accounts. Requires admin-roles, svc-groupids, and local-acct-grpids parameters. |
| **Default** | Discovers local accounts only. Uses federated_id field to determine if account is local. |

 

### Create Discovery Source

  

- Navigate to **Admin | Discovery**

- Click **Create** drop-down

- Select **Empty Discovery Source**

- Enter the Values below:    

    - **Name:** (example: ServiceNow Test Tenant)

    - **Site:** (Select Site Where Discovery will run)

    - **Source Type:** Empty

- Click Save

- Click **Cancel** on the Add Flow Screen

- Click **Add Scanner**

- Find the ServiceNow Tenant Scanner or the Scanner Created in the [Create ServiceNow Tenant Scanner Section](#create-servicenow-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **Lines Parse Format** Section Enter the Source Name (example: ServiceNow Tenant)

- Click **Save** 

- Click **Add Scanner**

- Find the ServiceNow Account Scanner or the Scanner Created in the [Create ServiceNow Account Scanner Section](#create-servicenow-account-scanner) and Click **Add Scanner**

- Select the Scanner just Created 

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privileged Account Secret created in the [Instructions file](../Instructions.md#create-secret-in-secret-server-for-the-servicenow-privileged-account)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret has to be setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- Click Save

  
  

### Next Steps

## Optional Report


In this section, There are instructions on creating an optional report to display user information found in the discovery.

  

- Login to Secret Server Tenant (If you have not already done so)

- Navigate to the Reports module

- click on the New Report Button

- Fill in the following values:
	
    - **Name:** The name of the Discovery Source you just Created in the [Create Discovery Source ](#create-discovery-source) Section (ex. MyDiscoverySource - Discovery )
	
    - **Description:** (Enter something meaningful to your organization)
	
    - **Category:** Select the Section where you would like the report to appear (ex. Discovery Scan)
	
    - Report SQL: Copy and Paste the SQL Query below
		***Note** " You must replace the WHERE d.DiscoverySourceId =  32 value with the Discovery Source ID of the Discovery source you are reporting on. You can find this by opening up the Discovery source and finding the ID in the URL 
   

``` SQL

SELECT

d.[ComputerAccountId]

,d.[CreatedDate]

,d.[AccountName] AS [Username]

,MIN(CASE  JSON_VALUE([adata].[value],'$.Name') WHEN  'host'  THEN  JSON_VALUE([adata].[value],'$.Value') END) AS [Domain]

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

 The ServiceNow configuration is now complete.  The next step is to run a manual discovery scan.

- Navigate to  **Admin | Discovery**

- Click the **Run Discovery Now** (Dropdown) and select **Run Discovery Now**

- Click on the **Network view** tab 

- You should now see the discovered Accounts. Use the filter option to find the Accounts easier