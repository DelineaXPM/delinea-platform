# Lumapps Local account password changing
*Heartbeating not available for these accounts*

## Pre-Requisistes
* [Lumapps base pre-requisites](./readme.md)
* [Lumapps local account template](./Template/Lumapps%20Local%20Account.xml) added to Secret Server
* [Password Changing Script](./RemotePasswordChanger/LumappsLocalAccountRPC.ps1) added to Secret Server
* [Stub Heartbeat Script](./RemotePasswordChanger/LumappsLocalAccountHeartbeatStub.ps1) added to Secret Server

## Create Password Changer
* Open ***Administation*** -> ***Remote Password Changing*** -> ***Options*** -> ***Configure Password Changers*** -> ***Create Password Changer***
* Base Password changer is ***PowerShell Script***
* Name is ***Lumapps Local Account***
* Verify Password
  * Select the [Lumapps Local Account Heartbeat Stub Script ](./RemotePasswordChanger/LumappsLocalAccountHeartbeatStub.ps1)
  * No arguments are needed
  * Click ***Save***
* Password Change Commands
  * Select the [Lumapps Local Account RPC Script ](./RemotePasswordChanger/LumappsLocalAccountRPC.ps1)
  * The arguments are  `$[1]$apiurl $[1]$ApplicationID $[1]$ApplicationSecret $[1]$OrganizationID $emailaddress $newpassword`
  * Click ***Save***
* Advanced Settings
  * Set ***Bypass verify after password change*** to ***Yes***

  # Configure Secret Template
  
