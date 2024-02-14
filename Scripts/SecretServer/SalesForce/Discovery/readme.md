
# Salesforce User Discovery

  

## Create Discovery Source

  

This scanner can help perform an Scan for Windows Systems based off an IP address range.

  

### Create Salesforce Tenant Scan Template

  

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

-  **Name:** (Example: Salesforce User)

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

- Name: ( example -Salesforce User Scanner)

- Description: (Enter something meaningful to your Organization)

- Active: (Checked)

- Script Type: Powershell

- Category: Discovery Scanner

- Merge Fields: Leave Blank

- Script: Copy and paste the Script included in the file [Salesforce User Discovery.ps1](./Salesforce%20Locaal%20Account%20Discovery.ps1)

- Click Save

- This completes the creation of the Local Account Discovery Script

  

### Create SalesforceTenant Scanner

  
  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** > Salesforce Tenant Scanner

-  **Description:** (Example - Base scanner used to discover SaaS applications)

-  **Discovery Type:** Host

-  **Base Scanner:** Host

-  **Input Template**: Manual Input Discovery

-  **Output Template:**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Scan Template Section](#create-salesforce-tenant-scan-template)

- Click Save

- This completes the creation of the Salesforce Tenant Scanner

  

### Create Salesforce User Scanner

  

- Log in to Secret Server Tenant

- Navigate to **ADMIN** > **Discovery** > **Configuration** >

- Click **Discovery Configuration Options** > **Scanner Definitions** > **Scanners**

- Click **Create Scanner**

- Fill out the required fields with the information

-  **Name:** (Example - Salesforce User Scanner)

-  **Description:** (Example - Discovers Salesforce Users according to configured privileged account template )

-  **Discovery Type:** Account

-  **Base Scanner:** PowerShell Discovery Create Discovery Script

-  **Input Template**: Salesforce Tenant (Use Template that Was Created in the [Salesforce Tenant Scan Template Section](#create-salesforce-tenant-scan-template))

-  **Output Template:**: Salesforce User (Use Template that Was Created in the [Salesforce User Scan Template Section](#create-account-scan-template))

-  **Script:** Salesforce Local Account Scanner (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))

-  **Script Arguments:**

``` powershell

"IAMUser-Advanced" $[1]$AccessKey $[1]$SecretKey $[1]$Admin-Criteria $[1]$SVC-Account-Criteria

```

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

- Find the Salesforce Tenant Scanner or the Scanner Created in the [Create Salesforce Tenant Scanner Section](#create-salesforcetenant-scanner)) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- In the **lines Parse Format** Section Enter the Source Name (example: Salesforce Tenant)

- Click **Save**

  

- Click **Add Scanner**

- Find the Salesforce Local Account Scanner or the Scanner Created in the [Create Salesforce User Scanner Section](#create-salesforce-user-scanner) and Click **Add Scanner**

- Select the Scanner just Created and Click **Edit Scanner**

- Click **Edit Scanner**

- Click the **Add Secret** Link

- Search for the Salesforce Service Account Secret created in the [instructions.md file](../Instructions.md)

- Check the Use Site Run As Secret Check box to enable it

**Note Default Site run as Secret had to ne setup in the Site configuration.

See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm?Highlight=site) Section in the Delinea Documentation

- Click Save

- Click on the Discovery Source yab and Click the Active check box

- This completes the creation of theDiscovery Source

  
  

### Next Steps

  

The Salesforce configuration is now complete. The next step is to run a manual discovery scan.

- Navigate to **Admin | Discovery**

- Click the **Run Discovery Noe** (Dropdown) and select **Run Discovery Now**

- Click on **Network view**

- Find the newly created discovery source and Users
  

This package is designed to discover and Manage Salesforce User Accounts. It will provide detailed instructions and the necessary Scripts to perform these functions. Before beginning to implement any of the specific processes it is a requirement to perform the tasks contained in the instructions.md document which can be found [here](./Instructions.md)

  
  

# Disclaimer

  

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.