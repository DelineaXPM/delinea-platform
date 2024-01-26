# Lumapps Local account password changing
*Heartbeat is not available for these accounts*

## Pre-Requisistes
- [Lumapps base pre-requisites](./readme.md)
- [Lumapps local account template](./Template/Lumapps%20Local%20Account.xml) added to Secret Server
- [Password Changing Script](./RemotePasswordChanger/LumappsLocalAccountRPC.ps1) added to Secret Server
- [Stub Heartbeat Script](./RemotePasswordChanger/LumappsLocalAccountHeartbeatStub.ps1) added to Secret Server

## Create Password Changer
- Open ***Administation*** -> ***Remote Password Changing*** -> ***Options*** -> ***Configure Password Changers*** -> ***Create Password Changer***
- Base Password changer is ***PowerShell Script***
- Name is ***Lumapps Local Account***
- Verify Password
  - Select the [Lumapps Local Account Heartbeat Stub Script ](./RemotePasswordChanger/LumappsLocalAccountHeartbeatStub.ps1)
  - No arguments are needed
  - Click ***Save***
- Password Change Commands
  - Select the [Lumapps Local Account RPC Script ](./RemotePasswordChanger/LumappsLocalAccountRPC.ps1)
  - The arguments are  `$$[1]$apiurl $[1]$ApplicationID $[1]$ApplicationSecret $OrganiztionID $emailaddress $newpassword`
  - Click ***Save***
- Advanced Settings
  - Set ***Bypass verify after password change*** to ***Yes***

# Configure Secret Template
- Install [Lumapps local account template](./Template/Lumapps%20Local%20Account.xml)
- Open the template and configure mappings
- Enable RPC
- Set Max Attempts and RPC Interval to desired values
- Do not enable Heartbeat as it is unavailable
- Select the ***Lumapps Local Account*** password changer
- Password fields
  - Domain -> URL
  - Password -> Password
  - User Name -> Emailaddress
 - Configure Launcher
 - Add ***Website Launcher***
   - Do not Restrict User input
   - Launcher FIelds
     - Password -> Password
     - URL -> URL
     - Username -> Emailaddress

# Create Secret
Create a new secret and enter the appropriate values for your account. URL should be the base login page of your instance.
Once you have entered the basic information, navigate to the ***Remote Password Changing*** tab and add the SaaS Client Credential template secret as ***Associated Secret number 1****
  
