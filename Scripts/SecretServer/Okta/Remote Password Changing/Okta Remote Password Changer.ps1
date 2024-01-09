[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Expected Args @("Okta base URL","Key ID KID","ClientID","Private Key", "Okta User Name", "New Password")
$args = @("dev-86659676.okta.com","0oab9qoksrf1erHqY5d7","kNIeP222d2M-0sZVB7ecPhfQIsizMT0tuC1RxvUjxps","Pem","rick.roca@delinea.com","@nd3rsL3327")

$oktaDomain = $args[0]
$clientId = $args[1]
$Kid = $args[2] 
$privateKeyPEM = $args[3]
$userId = $args[4]
$newPassword = $args[5]

#Script Constants
[string]$scope = "useraccount"
[string]$LogFile = "$env:Program Files\Thycotic Software Ltd\Distributed Engine\log\Okta-Integration.log"
[string]$LogFile = "c:\temp\Okta-Integration.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Okta Password Change"
#endregikon

#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,1,2,3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message
    )
    # Evaluate Log Level based on global configuration
    if ($ErrorLevel -le $LogLevel) {
        # Format message
        [string]$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm:sszzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        # Write Log data
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel,$logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
        # $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        # Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}
#endregion Error Handling Functions

function Get-BearerToken {
    param (
        [Parameter(Mandatory=$true, HelpMessage="JWT needed.")]
        [System.String]$JWT,
        [Parameter(Mandatory=$true, HelpMessage="scope needed; i.e.: okta.users.read")]
        [System.String]$Scope
    )
    try {
        Write-Log -Errorlevel 0 -Message "Obtaining Bearer Token"  
   
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        'Accept' = 'application/json'
    }
    $body = @{
        'grant_type' = 'client_credentials'
        'scope' = "$Scope"
        'client_assertion_type' = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        'client_assertion' = "$JWT"
    }
    $response =  Invoke-RestMethod -Method Post -Uri "https://$oktaDomain/oauth2/v1/token" -Headers $headers -Body $body
    $token = $response.access_token
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Bearer Token failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
Write-Log -Errorlevel 0 -Message "Successfully Obtained Bearer Token"  
return $token
}
try {
    Write-Log -Errorlevel 0 -Message "Obtaining JWT Token"  
    $JWT = Get-JWT -aud "https://$oktaDomain/oauth2/v1/token" -iss $clientId -sub $clientId  -Kid $Kid -privkey $privateKeyPEM
    Write-Log -Errorlevel 0 -Message "Successfully Obtained JWT Token" 
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining JWT Token failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}

$bearerToken = Get-BearerToken -JWT $JWT -Scope "okta.users.manage"  



 
try {
    Write-Log -Errorlevel 0 -Message "Attenpting Password Change"  
    $body = @{
        "credentials" = @{
          "password" = @{ "value" = $newpassword }
        }
      } | ConvertTo-Json -Depth 3
$url = "https://$oktaDomain/api/v1/users/$userid"
$response = Invoke-WebRequest -Uri $url -Headers @{"Authorization" = "Bearer $bearerToken";"Accept" = "application/json"} -Method Put -Body $body -ContentType "application/json" -DisableKeepAlive
Write-Log -Errorlevel 0 -Message "Successfully Chamged Password "
} catch {
  
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Password Change Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}




