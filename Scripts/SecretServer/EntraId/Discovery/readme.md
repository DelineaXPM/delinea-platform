# Entra ID Local Account Discovery

This Scanner will discover accounts as well as optionally qualify accounts as Admin, Service and Local Accounts.  It will also provide an option of including or excluding External (Guest) Accounts.
 
## Create Discovery Source

If you have not already done so, please click [here](../Instructions.md) to perform the basic configuration for interacting with Entra ID.

### Create Entra ID Tenant Scan Template

  

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click **Create Scan Template**

- Fill out the required fields:

    - **Name:** (Example: Entra ID Tenant)

    - **Active:** (Checked)

    - **Scan Type:** Host

    - **Parent Scan Template:** Host Range

    - **Fields:** Change HostRange to **tenant-Name**

- Click Save


### Create Account Scan Template

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tab 

- Fill out the required fields with the information

    - **Name:** (Example: Entra ID Account)

    - **Active:** (Checked)

    - **Scan Type:** Account

    - **Parent Scan Template:** Account(Basic)

    - **Fields:** 
    
        - Change Resource to Domain

        - Add field: Admin-Account (Leave Parent and Include in Match Blank)

        - Add field: Service-Account (Leave Parent and Include in Match Blank)

- Click Save

### Create Discovery Script

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Scripts**

- Click on **Create Script**

- Fill out the required fields:

    - **Name:** ( example: Entra ID Account Scanner)

    - **Description:** (Enter something meaningful to your Organization)

    - **Active:** (Checked)

    - **Script Type:** Powershell

    - **Category:** Discovery Scanner

    - **Merge Fields:** Leave Blank

    - **Script:** Copy and paste the Script included in the file [Entra ID Account Discovery](./EntraID%20Account%20Discovery.ps1)

- Click Save
  

### Create Entra ID Tenant Scanner

- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click the **Scanners** tab 

- Click **Create Scanner**

- Fill out the required fields with the information

    - **Name:** > Entra ID Tenant Scanner

    - **Description:** (Example - Base scanner used to discover Entra ID Accounts)

    - **Active:** (Checked)

    - **Discovery Type:** Host

    - **Base Scanner:**  Manual Input Scanner

    - **Input Template**: Discovery Source

    - **Output Template:**: Entra ID Tenant (Use Template that Was Created in the [Entra ID Tenant Scan Template Section](#create-entra-id-tenant-scan-template))

- Click Save


### Create Entra ID Account Scanner


- Log in to Secret Server Tenant (If you have not already done so)

- Navigate to **Admin** > **Discovery** > **Configuration** 

- Click on **Discovery Configuration Options** and select **Scanner Definitions** 

- Click the **Scan Template** tabs 

- Click the **Scanners** tab 

- Click **Create Scanner**

- Fill out the required fields:

    - **Name:** (Example: Entra ID Account Scanner)

    - **Description:** (Example: Discovers Entra ID accounts according to configured privileged account template )

    - **Active:** (Checked)
:
    - **Discovery Type:** Account

    - **Base Scanner:** PowerShell Discovery Create Discovery Script
    
    - **Allow OU Input:** (Checked)
    
    - **Input Template:**Entra ID Tenant (Use Template that Was Created in the [Entra ID tenant Scan Template Section](#create-entra-id-tenant-scan-template))

    - **Output Template:** Entra ID Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))

    -  **Script:** Entra ID Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

    - **Script Arguments:**
        **Note:** in the following arguments you must choose between the values enclosed in the <>

        - Detailed or Basic

            - **Detailed** will qualify wether accounts are considered Admin or Service Accounts based on the arguments provided. **Basic** wil only returned the Domain and Username of teh account
            
            - **True** will return all accounts including External (Guest) Accounts. **False** will only return users within the Tenant Entra ID Domain

    ```powershell

    $[1]$tenant-id $[1]$Application-Id $[1]$Client-Secret $[1]$admin-roles $[1]$Service-Account-Groups "<Detailed or Basic> <true or false>


    ```


- Click Save


### Create Discovery Source

  

- Navigate to **Admin | Discovery | Configuration**

- Click **Create** drop-down

- Click **Empty Discovery Source**

- Enter the Values below

  - **Name:** (example: Entra ID Tenant)

  - **Site:** (Select Site Where Discovery will run)

  - **Source Type:** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the Entra ID Tenant Scanner or the Scanner created in the [Entra ID Tenant Scanner Section](#Create Entra ID Tenant Scan) and Click **Add Scanner**

- Select the Scanner just created and Click **Edit Scanner**

- In the **Lines Parse Format** Section, enter the **Source Name** (example: Entra ID Tenant). This is only a label and is only used to identify the source. Choose a name that reflects and easily identifies the accounts being discovered by this Discovery Source

- Click **Save**

  

- Click **Add Scanner**

- Find the Entra ID Account Scanner or the Scanner created in the [Create Azure AD / Entra ID Account Scanner Section](#create-Azure AD / Entra ID-account-scanner) and Click **Add Scanner**

- Select the Scanner just created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Application Registration Secret created in the [instructions file](../Instructions.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.**

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

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

  

The Entra ID configuration is now complete. The next step is to run a manual discovery scan and view your discovered accounts in the **Admin | Discovery | Network View ** Panel
