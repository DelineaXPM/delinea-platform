# Slack Admin and Service Account Discovery

## Create Discovery Source

This scanner can help perform an Scan for user accounts within a Slack workspace. Account types will be destinguished by the appropriate roles designated by Slack.

### Create SaaS Scan Template
If this Script has already been created in another Delinea Integration package please skip to the [Create Account Scan Template](#create-account-scan-template) 

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: SaaS Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields**
        - Change HostRange to **tenant-url**
    - Click Save
    - This completes the creation of the Saas Scan Template Creation
 

### Create Account Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: Slack Account)
    - **Active:** (Checked)
    - **Scan Type:** Account
    - **Parent Scan Template:** Account(Basic)
    - **Fields**
        - Change Resource to **workspace-url**
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
    - Name: ( example -Slack User Account Scanner)
    - Description: (Enter something meaningful to your Organization)
    - Active: (Checked)
    - Script Type: Powershell
    - Category: Discovery Scanner
    - Merge Fields: Leave Blank
    - Script: Copy and paste the Script included in the file [Slack User Account Discovery](./Slack-Discovery.ps1)
    - Click Save
    - This completes the creation of the Account Discovery Script

### Create SaaS Tenant Scanner

If this Script has already been created in another Delinea Integration package please skip to the [Create Account Scanner Section](#create-slack-account-scanner ) 

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** > SaaS Tenant Scanner 
        - **Description:** (Example - Base scanner used to discover SaaS applications)
        - **Discovery Type:**  Host
    - **Base Scanner:**  Host
    - **Input Template**: Manual Input Discovery
    - **Output Template:**: Saas Tenant (Use Template that Was Created in the [SaaS Scan Template Section](#create-saas-scan-template))
    - Click Save
    - This completes the creation of the Saas Tenant Scanner

### Create Slack Account Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** (Example - Slack User Account Scanner) 
        - **Description:** (Example - Discovers Slack User accounts according to configured privileged account template )
        - **Discovery Type:**  Account
        - **Base Scanner:** PowerShell Discovery
        - **Input Template**: SaaS Tenant (Use Template that Was Created in the [SaaS Scan Template Section](#create-saas-scan-template))
        - **Output Template:**: Slack Account  (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))
        - **Script:** Slack User Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
        - **Script Arguments: ``` Advanced $[1]$OAuthToken $[1]$admin-roles $[1]$svcacct-roles ```
        - Click Save
        - This completes the creation of the Slack Account Scanner

### Create Discovery Source

- Navigate to **Admin | Discovery | Configuration**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
    - **Name:** (example: Slack Tenant [Workspace Name])
    - **Site** (Select Site Where Discovery will run)
    - **Source Type** Empty
- Click Save
- Click Cancel on the Add Flow Screen
- Click **Add Scanner**
- Find the Saas Tenant Scanner or the Scanner Created in the [Create Saas Tenant Scanner Section](#create-saas-tenant-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- In the **lines Parse Format** Section Enter the Source Name (example: Slack Tenant)
- Click **Save**

- Click **Add Scanner**
- Find the Slack User Account Scanner  or the Scanner Created in the [Create Slack User Account Scanner Section](#create-slack-account-scanner) and Click **Add Scanner**
- Select the Scanner just Created and Click **Edit Scanner**
- Click **Edit Scanner**
- Click the **Add Secret** Link
- Search for the Privileged Account Secret created in the [Instructions.md file](../Instructions.md)
- Check the Use Site Run As Secret Check box to enable it
    **Note Default Site run as Secret had to ne setup in the Site configuration.
    See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation
- Click Save
- Click on the Discovery Source tab and Click the Active check box
- This completes the creation of theDiscovery Source


### Next Steps

 The Slack Discovery configuration is now complete.  The next step is to run a manual discovery scan.
- Navigate to  **Admin | Discovery**
- Click the **Run Discovery Now** (Dropdown) and select **Run Discovery Now**
- Click on the **Network view** Button in the upper right corner
- Click on the newly created discovery source
- Click the **Domain \ Cloud Accounts** tab to view the discovered accounts

