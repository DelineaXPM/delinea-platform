# Salesforce Account Discovery



## Create Discovery Source

  

This scanner will perform Discovery of Salesforce users

  

### Create Salesforce Scan Template

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Salesforce Tenant)

-  **Active:** (Checked)

-  **Scan Type:** Host

-  **Parent Scan Template:** Host Range

-  **Fields**

- Change HostRange to **tenant-url**

- Click Save

- This completes the creation of the Salesforce Scan Template Creation

  

### Create Account Scan Template

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** > **Scanner Definition** > **Scan Templates**

- Click **Create Scan Template**

- Fill out the required fields with the information

-  **Name:** (Example: Salesforce Account)

-  **Active:** (Checked)

-  **Scan Type:** Account

-  **Parent Scan Template:** Account(Basic)

-  **Fields**

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

- Name: ( example - Salesforce Local Account Scaner)

- Description: (Enter something meaningful to your Orgabization)

- Active: (Checked)

- Script Type: Powershell

- Category: Discovery Scanner

- Merge Fields: Leave Blank

- Script: Copy and paste the Script included in the file [Salesforce Account Loacl Account Discoverey.ps2](./Salesforce%20Locaal%20Account%20Discovery.ps1)

- Click Save

- This completes the creation of the Local Account Discovery Script

  

### Create Salesforce Tenant Scanner


- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** > Salesforce Tenant Scanner

-  **Description:** (Example - Base scanner used to discover Salesforce tenant)

-  **Discovery Type:** Host

-  **Base Scanner:** Host

-  **Input Template**: Manual Input Discovery

-  **Output Template:**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Scan Template Section](#create-salesforce-scan-template))

- Click Save

- This completes the creation of the Salesforce Tenant Scanner

  

### Create Salesforce Account Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** (Example - Salesforce Local Account Scanner)

-  **Description:** (Example - Discovers Salesforce local accounts according to configured privileged account Secret )

-  **Discovery Type:** Account

-  **Base Scanner:** PowerShell Discovery Create Discovery Script

-  **Input Template**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Scan Template Section](#create-salesforce-scan-template))

-  **Output Template:**: Salesforce Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))

-  **Script:** Salesforce Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

-  **Script Arguments: **Advanced $[1]$tenant-url $[1]$username $[1]$password $[1]$client-id $[1]$client-secret $[1]$admin-roles $[1]$sac-groupids $[1]$local-acct-grpids**

- Click Save

- This completes the creation of the Salesforce Account Scanner

  

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

- Find the Salesforce Tenant Scanner or the Scanner Created in the [Create Saas Tenant Scanner Section](#create-salesforce-tenant-scanner) and Click **Add Scanner**

- Select the Scanner just Ceated and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: ServiceNow Test Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the ServiceNow Local Account Scanner or the Scanner Creatted in the [Create Salesforce Account Scanner Section](#create-servicenow-account-scanner) and Click **Add Scanner**

- Select the Scanner just Ceated and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Privoleged Account Secret created in the [Instructions.md file](../Instructions.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret has to be setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source tab and Click the Active check box

- This completes the creation of theDiscovery Source

  
  

### Next Steps

  

The Salesforce configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**

- Click on the **Network view** Button in the upper right corner

- Click on the newly cretaed discocvery source

- Click the **Domain \ Cloud Accounts** yab to view the discovered accounts