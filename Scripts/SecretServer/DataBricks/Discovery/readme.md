# Databricks Secret Server integration

## Create Discovery Source

This scanner can help perform an Scan for Windows Systems based off an IP address range.

### Create Databricks Tenant Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Nmae:** (Evxample: Databrikcs Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields**
        - Change HostRange to **tenant-url**
    - Click Save
    - This completes the creation of the Saas Scan Template Creation
 

### Create Databricks Account Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Nmae:** (Evxample: Databricks User Advanced)
    - **Active:** (Checked)
    - **Scan Type:** Account
    - **Parent Scan Template:** Account(Basic)
    - **Fields**
        - Change Resource to **tenant-url**
        - Add field: Admin-Account (Leave Parent and Include in Match Blank)
        - Add field: Service-Account (Leave Parent and Include in Match Blank)
        - Add field: Local-Account (Leave Parent and Include in Match Blank)
    - Click Save
    - This completes the creation of the Account Scan Template Creation
 
### Create Discovery Script

- Log in to Secret Server Tenant
- Navigate to**ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields with the information from the application registration
    - Name: ( example - Datbricks User Scaner)
    - Description: (Enter something meaningful to your Orgabization)
    - Active: (Checked)
    - Script Type: Powershell
    - Category: Discovery Scanner
    - Merge Fields: Leave Blanck
    - Script: Copy and paste the Script included in the file [Databricks Account Discovery.ps2](./DataBricks-Account-Discovery.ps1)
    - Click Save
    - This completes the creation of the Local Account Discovery Script

### Create Databricks Tenant Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** > Databricks Tenant Scanner 
        - **Description:** (Example - Databricks Workspaces)
        - **Discovery Type:**  Host
    - **Base Scanner:**  Host
    - **Input Template**: Manual Input Discovery
    - **Output Template:**: Databricks Tenant (Use Temaplte that Was Created in the [Databricks Tenant Scan Template Section](#create-databricks-tenant-scan-template)
    - Click Save
    - This completes the creation of the AWS Tenant Scanner

### Create Databricks User Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** (Example - Databricks User Scanner) 
        - **Description:** (Example - Discovers Databricks Users according to configured privileged account template )
        - **Discovery Type:**  Account
        - **Base Scanner:** PowerShell Discovery Create Discovery Script
        - **Input Template**: Databrikcs Tenant (Use Temaplte that Was Created in the [Databricks Tenant Scan Template Section](#create-aws-tenant-scan-template))
        - **Output Template:**: Databricks User  (Use Temaplte that Was Created in the [Databricks User Advanced Scan Template Section](#create-databricks-account-scan-template))
        - **Script:** ServiceNow Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
        - **Script Arguments:** 
        ``` powershell
        "Advanced" $[1]$Tenant-url $[1]$client-Id $[1]$client-Secret $[1]$Admin-Criteria $[1]$SVC-Account-Criteria $[1]$Domain-Acct-Criteria
        ```
        - Click Save
        - This completes the creation of the ServiceNow Account Scanner

### Create Discovery Source

- Navigate to **Admin | Discovery | Configuration**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
    - **Name:** (example: Databricks Tenant) As created in the [Create Databricks Tenant Scanner](#create-databricks-tenant-scanner)
    - **Site** (Select Site Where Discovery will run)
    - **Source Type** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click **Add Scanner**
- Find the Databricks Tenant Scanner or the Scanner Creatted in the [Create Databricks Tenant Scanner Section](#create-databricks-tenant-scanner) and Click **Add Scanner**
- Select the Scanner just Ceated and Click **Edit Scanner**
- In the **lines Parse Format** Section Enter the Source Name (example: Databricks Tenant)
- Click **Save**

- Click **Add Scanner**
- Find the Databricks Local Account Scanner  or the Scanner Creatted in the [Create Databricks User Scanner Section](#create-databricks-user-scanner) and Click **Add Scanner**
- Select the Scanner just Ceated and Click **Edit Scanner**
- Click **Edit Scanner**
- Click the **Add Secret** Link
- Search for the Databricks Privileged Account Secret created in the [instructions.md file](../instructions.md#create-secret-in-secret-server-for-the-databrikcs-privileged-account)
- Check the Use Site Run As Secret Check box to enable it
    **Note Default Site run as Secret had to ne setup in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box
- This completes the creation of theDiscovery Source


### Next Steps

 The Databricks configuration is now complete.  The next step is to run a manual discovery scan.
- Navigate to  **Admin | Discovery**
- Click the **Run Discovery Noe** (Dropdon) and select **Run Discovery Now**
- Click on  **Network view** 
- Find the newly cretaed discocvery source and Users


