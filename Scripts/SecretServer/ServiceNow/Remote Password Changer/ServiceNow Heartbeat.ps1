
#Expected Arguments @("baseURL", "privUsername", "privPassword", "clientId", "clientSecret", "username", "password")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Set Parameters and Variables
[string]$baseURL = $args[0]
[string]$tokenUrl = "$baseURL/oauth_token.do"
[string]$api = "$baseURL/api/now"
[string]$privUsername = $args[1]
[string]$privPassword = $args[2]
[string]$clientId = $args[3]
[string]$clientSecret = $args[4]
[string]$username = $args[5]
[string]$password = $args[6] 


#Script Constants
[string]$scope = "useraccount"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ServiceNow-Connector.log"
  [int32]$LogLevel = 3
[string]$logApplicationHeader = "ServiceNow Heartbeat"
#endregion

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
        [string]$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        # Write Log data
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel,$logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}
#endregion Error Handling Functions

#region Get Token
function Get-BearerToken {
    param (
        [Parameter(Mandatory=$true, HelpMessage="Privileged User Name")]
        [System.String]$privUsername,
        [Parameter(Mandatory=$true, HelpMessage="Privileged User Password")]
        [System.String]$privPassword,
        [Parameter(Mandatory=$false, HelpMessage="scope needed")]
        [System.String]$Scope,
        [Parameter(Mandatory=$true, HelpMessage="Root Url to hit to get bearer token")]
        [System.String]$Url,
        [Parameter(Mandatory=$true, HelpMessage="client_id")]
        [System.String]$clientId,
        [Parameter(Mandatory=$true, HelpMessage="client_secret")]
        [System.String]$clientSecret
      
    )
    Write-Log -ErrorLevel 0 -Message "Obtaining Access Token"
    $body = @{
        grant_type    = "password"
        client_id     = $clientId
        client_secret = $clientSecret
        username      = $privUsername
        password      = $privPassword
        scope         = $scope
    }
    try {
        $result = Invoke-RestMethod -Method Post -Uri $Url -Body $body
        $token = $result.access_token
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Retrieving Access Token Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $token
}
#endregion
function Test-PasswordVerification {
    param (
        [Parameter(Mandatory=$true, HelpMessage="Username to check password")]
        [System.String]$Username,
        [Parameter(Mandatory=$true, HelpMessage="Password value")]
        [System.String]$Password,
        [Parameter(Mandatory=$true, HelpMessage="Request headers")]
        [hashtable]$headers
    )
    try{
        $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $creds = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)
        $response = Invoke-RestMethod -Uri "$api/table/sys_user?sysparm_limit=1" -Credential $creds   -Method Get
        if ($response.result.Count -eq 1) {
            
            $result = $true
        }

    }
    catch {
        $err = $_
        Write-Log -ErrorLevel 0 -Message "Verify Password Failed - Bad Username or Password"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $result
}
#
$token = Get-BearerToken -privUsername $privUsername -privPassword $privPassword -Scope $scope -Url $tokenUrl -clientId $clientId -clientSecret $clientSecret
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}
#

 $result = Test-PasswordVerification -Username $username -Password $password -headers $headers
 return $result
