# Jamf Local Account Discovery

## Create Discovery Source
This scanner will perform a Scan for user accounts within Jamf Pro. Account types will be distinguished by appropriate roles designated by Jamf.

### Create SaaS Scan Template
If this Script has already been created in another Delinea Integration package please skip to the [Create Account Scan Template](#create-account-scan-template )

- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> ***Scanner Definition*** -> ***Scan Templates***
- Click ***Create Scan Template***
- Fill out the required fields with the information
  - ***Name:*** SaaS Tenant
  - ***Active:*** Checked
  - ***Scan Type:*** Host
  - ***Parent Scan Template:*** Host Range
  - ***Fields***
    - Change HostRange to ***tenant-url***
- Click ***Save***

### Create Account Scan Template
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** -> ***Scanner Definition*** -> ***Scan Templates***
- Click ***Create Scan Template***
- Fill out the required fields with the information
  - ***Name:*** Jamf Account
  - ***Active:*** Checked
  - ***Scan Type:*** Account
  - ***Parent Scan Template:*** Account(Basic)
  - ***Fields***
  - Change Resource to ***tenant-url***
- Add field: Admin-Account (Leave Parent and Include in Match Blank)
- Add field: Service-Account (Leave Parent and Include in Match Blank)
- Add field: Local-Account (Leave Parent and Include in Match Blank)
- Click ***Save***

### Create Discovery Script
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Scripts***
- Click on ***Create Script***
- Fill out the required fields with the information from the application registration
  - ***Name:*** Jamf Local Account Scanner or a descriptive value
  - ***Description:*** Enter something meaningful to your Organization
  - ***Active:*** Checked
  - ***Script Type:*** PowerShell
  - ***Category:*** Discovery Scanner
  - ***Merge Fields:*** Leave Blank
  - ***Script:*** Copy and paste the [Jamf Discovery script](./Jamf%20Discovery.ps1)
- Click ***Save***

### Create SaaS Tenant Scanner
If this Script has already been created in another Delinea Integration package please skip to the [create account scanner section](#create-Jamf-account-scanner)
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** >
- Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
- Click ***Create Scanner***
- Fill out the required fields with the information
  - ***Name:*** -> SaaS Tenant Scanner
  - ***Description:*** (Example - Base scanner used to discover SaaS applications)
  - ***Discovery Type:*** Host
  - ***Base Scanner:*** Host
  - ***Input Template:*** Manual Input Discovery
  - ***Output Template:***: SaaS Tenant or the template name that was created in the [SaaS scan template section](#create-saas-scan-template))
- Click ***Save***

### Create Jamf Account Scanner
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Discovery*** -> ***Configuration*** >
- Click ***Discovery Configuration Options*** -> ***Scanner Definitions*** -> ***Scanners***
- Click ***Create Scanner***
- Fill out the required fields with the information
  - ***Name:*** Jamf Local Account Scanner or the name you used in in the [create SaaS tenant scanner section](#create-saas-tenant-scanner)
  - ***Description:*** Discovers Jamf local accounts according to configured Client Credentials template
  - ***Scanner Type:*** Account
  - ***Base Scanner:*** PowerShell Discovery
  - ***Input Template:*** SaaS Tenant or the template name that was created in the [SaaS scan template section](#create-saas-scan-template))
  - ***Output Template:***: Jamf Account (Use Template that Was Created in the [Create Account Scan Template Section](#create-account-scan-template))
  - ***Script:*** Jamf Local Account Discovery (Use Script Created in the [Create Discovery Script Section](#create-discovery-script))
  - ***Script Arguments:***  ```Advanced $[1]$tenant-url $[1]$clientid $[1]$clientsecret $[1]$admin-roles $[1]$Service-Account-Group-Ids```
- Click ***Save***

### Create Discovery Source
- Navigate to ***Administration*** -> ***Discovery***
- Click ***Create*** (drop-down)
- Click ***Empty Discovery Source***
- Enter the Values below
  - ***Name:*** Jamf Tenant or other unique name
  - ***Site*** Select Site Where Discovery will run
  - ***Source Type*** Empty
- Click ***Save***
- Click ***Cancel*** on the Add Flow Screen
- Click ***Add Scanner***
- Find the SaaS Tenant Scanner or the Scanner created in the [create SaaS tenant scanner section](#create-saas-tenant-scanner) and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner***
- In the ***lines Parse Format*** Section Enter the Source Name (example: Jamf Tenant)
- Click ***Save***
- Click ***Add Scanner***
- Find the Jamf Local Account Scanner or the Scanner created in the [create Jamf account scanner section](#create-Jamf-account-scanner) and Click ***Add Scanner***
- Select the Scanner just Created and Click ***Edit Scanner***
- Click ***Edit Scanner***
- Click the ***Add Secret*** Link
- Search for the Client Credential Secret created in the [instructions file](../Instructions.md)
- Check the ***Use Site Run As Secret*** Check box to enable it
> [!NOTE]
> Default Site run as Secret had to be setup in the Site configuration.
> 
> See the [Setting the Default PowerShell Credential for a Site](https://docs.delinea.com/online-help/secret-server/authentication/secret-based-credentials-for-scripts/index.htm) Section in the Delinea Documentation

- Click ***Save***
- Click on the ***Discovery Source*** tab 
- For the ***State*** option click the check box to set the source to active

## Next Steps
The Jamf configuration is now complete. The next step is to run a manual discovery scan.
- Navigate to ***Administration*** -> ***Discovery***
- Click the ***Run Discovery Now*** (Dropdown) and select ***Run Discovery Now***
- Click on the ***Network view*** tab 
- Click on the ***Toggle Panel*** :file_folder: icon in the upper left corner below the ***Analysis*** tab
- Click on the newly created discovery source to see the discovered accounts