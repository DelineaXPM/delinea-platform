# Adobe Acrobat Sign Account Discovery

  

## Create Discovery Source

  

### Create Adobe Sign Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Adobe Sign Tenant)

-  **Active:** (Checked)

-  **Scan Type:** Host

-  **Parent Scan Template:** Host Range

-  **Fields**

- Change HostRange to **tenant-url**

- Click Save

- This completes the creation of the Adobe Sign Scan Template Creation

  

### Create Account Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Adobe Sign Account)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

- Change Resource to **tenant-url**

- Add field: Account-Admin (Leave Parent and Include in Match Blank)

- Add field: Local-Admin (Leave Parent and Include in Match Blank)

- Add field: Group-Admin (Leave Parent and Include in Match Blank)

- Add field: Service-Account (Leave parent and Include in Match Blank)

- Click Save

- This completes the creation of the Account Scan Template Creation

### Create Discovery Script

  

- Log in to Secret Server Tenant

- Navigate to**ADMIN** > **Scripts**

- Click on **Create Script**

- Fill out the required fields with the information from the application registration

- Name: ( example Adobe Sign Account Scanner)

- Description: (Enter something meaningful to your Organization)

- Active: (Checked)

- Script Type: Powershell

- Category: Discovery Scanner

- Merge Fields: Leave Blank

- Script: Copy and paste the Script included in the file [AdobeSign Discovery.ps1](./AdobeSign%20Discovery.ps1)

- Click Save

- This completes the creation of the  Account Discovery Script

  

### Create Adobe Sign Tenant Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** > Adobe Sign Tenant Scanner

-  **Description:** (Example - Base scanner used to discover Adobe Sign)

-  **Discovery Type:** Host

-  **Base Scanner:** Manual Input Discovery

-  **Input Template**: Discovery Source

-  **Output Template:**: Adobe Sign Tenant (Use Temaplte that Was Created in the [Adobe Sign Scan Template Section](#create-adobe-sign-scan-template))

- Click Save

- This completes the creation of the Adobe Sign Tenant Scanner

  

### Create Adobe Sign Account Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** (Example - Adobe Sign Account Scanner)

-  **Description:** (Example - Discovers Adobe Sign accounts according to configured privileged account template )

-  **Discovery Type:** Accounts

-  **Base Scanner:** PowerShell Discovery Create Discovery Script

-  **Allow OU Import**: Yes

-  **Input Template**: Adobe Sign Tenant (Use Temaplte that Was Created in the [Adobe Sign Scan Template Section](#create-saas-scan-template))

-  **Output Template:**: Adobe Sign Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))

-  **Script:** Adobe Sign Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

-  **Script Arguments:**

```PowerShell

$[1]$search-mode $[1]$tenant-url $[1]$access-token $[1]$saml-enabled $[1]$service-account-group

```

- Click Save

- This completes the creation of the Adobe Sign Account Scanner

  

### Create Discovery Source

  

- Navigate to **Admin | Discovery | Discovery Sources**

- Click **Create** drop-down

- Click **Empty Discovery Source**

-Enter the Values below

- **Name:** (example: Adobe Sign Test Tenant)

- **Site** (Select Site Where Discovery will run)

- **Source Type** Empty

- Click Save

- Click Cancel on the Add Flow Screen

- Click **Add Scanner**

- Find the SaaS Tenant Scanner or the Scanner Created in the [Create Adobe Sign Tenant Scanner Section](#create-abode-sign-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Ceated and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: Adobe Sign Test Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the Adobe Sign Account Scanner or the Scanner Creatted in the [Create ServiceNow Account Scanner Section](#create-adobe-sign-account-scanner) and Click **Add Scanner**

- Select the Scanner just Ceated and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privoleged Account Secret created in the [Overview.md file](../Overview.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret has to be setup in the Site configuration if not already configured.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source yab and Click the Active check box

- This completes the creation of theDiscovery Source

  
  

### Next Steps

  

The ServiceNow configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdon) and select **Run Discovery Now**

- Click on the **Network view** Button in the upper right corner

- Click on the newly created discovery source

- Click the **Domain \ Cloud Accounts** yab to view the discovered accounts