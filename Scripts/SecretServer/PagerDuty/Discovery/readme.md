# PagerDuty Account Discovery

## Create Discovery Source

### Create PagerDuty Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
- Click **Create Scan Template**
- Fill out the required fields with the information
    - **Name:** (Example: PagerDuty Tenant)
    - **Active:** (Checked)
    - **Scan Type:** Host
    - **Parent Scan Template:** Host Range
    - **Fields**
        - Change HostRange to **tenant-url**
    - Click Save
    - This completes the creation of the PagerDuty Scan Template Creation
 

### Create PagerDuty Account Scan Template

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** >   **Scanner Definition** > **Scan Templates** 
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
    - This completes the creation of the PagerDuty Account Scan Template Creation
 
### Create Local Account Discovery Script

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Scripts**
- Click on **Create Script**
- Fill out the required fields with the information from the application registration
    - Name: ( example PagerDuty Account Scanner)
    - Description: (Enter something meaningful to your Organization)
    - Active: (Checked)
    - Script Type: Powershell
    - Category: Discovery Scanner
    - Merge Fields: Leave Blank
    - Script: Copy and paste the Script included in the file [PagerDuty Discovery.ps1](./PagerDuty%20Discovery.ps1)
    - Click Save
    - This completes the creation of the Local Account Discovery Script

### Create PagerDuty Tenant Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
    - Click **Create Scanner**
    - Fill out the required fields with the information
        - **Name:** > PagerDuty Tenant Scanner 
        - **Description:** (Example - Base scanner used to discover PagerDuty)
        - **Discovery Type:**  Host
    - **Base Scanner:**  Manual Input Discovery
    - **Input Template**: Discovery Source
    - **Output Template:**: PagerDuty Tenant (Use Template that Was Created in the [PagerDuty Scan Template Section](#create-PagerDuty-scan-template))
    - Click Save
    - This completes the creation of the PagerDuty Tenant Scanner

### Create PagerDuty Account Scanner

- Log in to Secret Server Tenant
- Navigate to **ADMIN** > **Discovery** > **Configuration** > 
    - Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**
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
        - This completes the creation of the PagerDuty Account Scanner

### Create Discovery Source

- Navigate to **Admin | Discovery | Discovery Sources**
- Click **Create** drop-down
- Click **Empty Discovery Source**
-Enter the Values below
    - **Name:** (example: PagerDuty Test Tenant)
    - **Site** (Select Site Where Discovery will run)
    - **Source Type** Empty
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
- This completes the creation of the Discovery Source


### Next Steps

 The PagerDuty configuration is now complete.  The next step is to run a manual discovery scan.
- Navigate to  **Admin | Discovery**
- Click the **Run Discovery Now** (Dropdown) and select **Run Discovery Now**
- Click on the **Network view** Button in the upper right corner
- Click on the newly created discovery source
- Click the **Domain \ Cloud Accounts** tab to view the discovered accounts