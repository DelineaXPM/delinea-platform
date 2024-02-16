Import-Module -Name ".\Delinea.PoSH.Helpers\Utils.psm1" # How are we defining this?
  <#
  .SYNOPSIS
  Remote Password Change for Workday Privileged Accounts
  
  .DESCRIPTION
  This script will Rotate the Password of the defined account with the password provided in the argument
  .EXAMPLE
  An example
  This is an example of Args to be passed into the Script
  $args = @("TargetUserName","WorkdayDefinedGroups","clientid", "username", "SOAPEndpoint", "TokenUri", "Password", "privateKeyPEM")
  .NOTES
  General notes
  1. TargetUserName: Username of the targeted account to rotate the PW of
  2. WorkdayDefinedGroups: Target Admin account group membership String, but can be null and will pull all groups that have the phrase "admin" in them
  3. ClientID: Client ID of the OAUTH2 service account
  4. Username: The issuer of the token; in a non UPN Format
  5. SOAPEndpoint: SOAP endpoint Root. 
  6. TokenUri: The token uri that is for OAUTH2 authentication
  7. Password: Password to be rotated as
  #>


[string]$TargetUserName = $args[0]
[string]$clientid = $args[1]
[string]$username = $args[2] # Must be in this format or WILL NOT WORK
[string]$SOAPEndpoint = $args[3]
[string]$TokenUri = $args[4]
[string]$Password = $args[5]
$privateKeyPEM  =args[6]

#Logging vars
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Workday-RemotePasswordChanger.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Workday RemotePasswordChanger"
[bool]$LogFileCheck = $true

function Get-WorkdayJWTToken{
    try{
        $jwttoken = $(Get-JWT -aud "wd2" -iss $clientid -sub $username -privkey $privateKeyPEM -exp 5)
        return $(Invoke-RestMethod -Method Post -Uri $TokenUri  -Headers @{"Content-Type" = "application/x-www-form-urlencoded"} -Body "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$($jwttoken)").access_token
      }
      catch {
        $exception = New-Object System.Exception "Caught some general error When doing The JWT auth: `nMessage: $($_.Exception.Message)."
        Write-Log -Errorlevel 2 -Message "Caught some general error When doing the JWT auth: `nMessage: $($_.Exception.Message)." -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile
        throw $exception
      }
}
Write-Log -ErrorLevel 0 -Message "Going to rotate the Workday PW of: $($TargetUserName). A SOAP request will be made to do this" -logApplicationHeader $logApplicationHeader -LogLevel $LogLevel -LogFile $LogFile -LogFileCheck $LogFileCheck
$token = Get-WorkdayJWTToken
$headers = @{
    "Authorization" = "Bearer $token"
}
#`"$TargetUserName`"

$soapRequestToResetAPW = [xml]@"
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <env:Body>
        <bsvc:Workday_Account_for_Worker_Update
            xmlns:bsvc="urn:com.workday/bsvc"
            bsvc:version="v41.0">
            <bsvc:Non_Worker_Reference>
                <bsvc:ID bsvc:type="WorkdayUserName">$($TargetUserName) </bsvc:ID>
            </bsvc:Non_Worker_Reference>
            <bsvc:Workday_Account_for_Worker_Data>
                <bsvc:User_Name>$($TargetUserName) </bsvc:User_Name>
                <bsvc:Password>$($Password)</bsvc:Password>
            </bsvc:Workday_Account_for_Worker_Data>
        </bsvc:Workday_Account_for_Worker_Update>
    </env:Body>
</env:Envelope>
"@


try{
    Invoke-RestMethod -Uri "$SOAPEndpoint/Human_Resources/v41.2" -Method Post -Headers $headers -Body $soapRequestToResetAPW
}
  catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Error gettin JWT Token"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception <#Do this if a terminating exception happens#>
  }
return $true

