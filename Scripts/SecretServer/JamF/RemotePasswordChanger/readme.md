# Jamf Remote Password changer
The steps below show how to Set up and configure a Jamf Remote Password Changer in Delinea Secret Server.

If you have not already done so, please follow the steps in the [Instructions document](../Instructions.md)

## Create Scripts

### Remote Password Changer Script
1. Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Scripts***
- Click on ***Create Script***

- Fill out the required fields
  - ***Name:*** Jamf Remote Password Changer
  - ***Description:*** Enter something meaningful to your Organization)
  - ***Active*** (Checked)
  - ***Script Type:*** PowerShell
  - ***Category:*** Password Changing
  - ***Merge Fields:*** Leave Blank
  - ***Script***: Copy and paste the [Jamf Remote Password Changer script](./Jamf%20RPC.ps1)
- Click ***Save***

### Heartbeat Script
- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Scripts***
- Click on ***Create Script***
- Fill out the required fields
  - ***Name:*** Jamf Heartbeat or other descriptive name
  - ***Description:*** Enter something meaningful to your Organization
  - ***Active*** Checked
  - ***Script Type:*** PowerShell
  - ***Category:*** Heartbeat
  - ***Merge Fields:*** Leave Blank
  - ***Script:*** Copy and paste the [Jamf Heartbeat script](./Jamf%20Heartbeat.ps1)
- Click ***Save***

## Create Password Changer

- Log in to Secret Server Tenant
- Navigate to ***Administration*** -> ***Remote Password Changing***
- Click on ***Options*** (Dropdown List) and select ***Configure Password Changers***
- Click on ***Create Password Changer***
- Click on ***Base Password Changer*** (Dropdown List) and Select PowerShell Script
- Enter a ***Name*** Jamf Remote Password Changer or other descriptive name
- Click ***Save***
- Under the ***Verify Password Changed Commands*** section, Enter the following information:
  - ***PowerShell Script*** (DropdownList) Select ***Jamf Heartbeat*** or whatever you named the heartbeat script created in the [heartbeat script](#heartbeat-script) Section)
  - ***Script Args:*** ```$tenant-url $username $password ```
- Click ***Save*** in the ***Verify Password Changed*** section

- Under the ***Password Change Commands*** Section, Enter the following information:
  - ***PowerShell Script*** (DropdownList) Select ***Jamf Remote Password Changer*** *** or whatever you named the heartbeat script created in the [remote password changer script](#remote-password-changer-script) Section
  - ***Script Args:*** ```$tenant-url $username $newpassword $[1]$clientId $[1]$clientSecret ```
- Click ***Save*** in the ***Password Change Commands*** section

## Update Jamf User template
- Log in to Secret Server Tenant 
- Navigate to ***Administration*** -> ***Secret Templates***
- Find and Select the Jamf User Template created in the [Instructions Document](../Instructions.md)
- Select the ***Mapping*** Tab
- In the ***Password Changing*** section, click edit and fill out the following
  - ***Enable RPC*** Checked
  - ***RPC Max Attempts*** 24
  - ***RPC Interval Hours*** 4
  - ***Enable Heartbeat*** Checked
  - ***Heartbeat Interval Hours*** 4
- ***Password Type to use*** Select ***Jamf Remote Password Changer*** or the Password Changer create in the [Create Password Changer Section](#create-password-changer)
- In the ***Password Type Fields*** Section, fill out the following
  - ***Domain*** -> ***tenant-url***
  - ***Password*** -> ***Password***
  - ***Username*** -> ***Username***
- Click ***Save***

## Update Remote Password Changer
- Navigate to ***Administration*** -> ***Remote Password Changing***
- Click on ***Options*** (Dropdown List) and select ***Configure Password Changers***
- Select the ***Jamf Remote Password Changer*** or the password changer created in the [Create Password Changer](#create-password-changer) section
- Click ***Configure Scan Template at the bottom of the page***
- Click ***Edit***
- Click the ***Scan Template to use*** (Dropdown List) Select the ***Jamf User template*** created in the [Instructions Document](../Instructions.md)
- Map the following fields that appear after the selection
  - ***tenant-url*** -> Domain
  - ***Username*** -> username
  - ***Password*** -> password
- Leave all other fields blank
- Click ***Save***

> [!WARNING]
> When creating secrets with the Jamf User Account template, you must assign the appropriate privileged account secret to the Associated Secrets in position 1 (i.e. Jamf Client Credentials secret from [Create Secret in Secret Server for the Jamf Client Credentials Account](../Instructions.md/#create-secret-in-secret-server-for-the-jamf-client-credentials-account)). 
> 
> More information on associated accounts and secret policies can be found on https://docs.delinea.com 
> - [Privileged Accounts and Reset Secrets](https://docs.delinea.com/online-help/secret-server/remote-password-changing/privileged-accounts-and-reset-secrets/index.htm)
> - [Creating Secret Policies](https://docs.delinea.com/online-help/secret-server/secret-management/procedures/creating-secret-policies/index.htm)