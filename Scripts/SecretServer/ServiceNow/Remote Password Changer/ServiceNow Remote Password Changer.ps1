
#Expected Arguments @("baseURL", "privUsername", "privPassword", "clientId", "clientSecret", "username", "newPassword")
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
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ServiceNow-Password_Rotate.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "ServiceNow Password Change"
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
    # Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcAccountIds.result.Count) SErvice Accounts"  
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

#region RPC Functions

function Get-ServiceNowUserInfo {
    param (
        [Parameter(Mandatory=$true, HelpMessage="Username to check PW")]
        [System.String]$Username
    )
    try{
        $uri ="$api/table/sys_user?sysparm_query=user_name=$Username"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        $user_id =  $response.result.sys_id
  
    }
    catch {
        $err = $_
        Write-Log -ErrorLevel 0 -Message "Retrieving ServiceNow UserID  Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    
    return $user_id      
}

function Reset-SNowPassword{
    param (
        [Parameter(Mandatory=$true, HelpMessage="User id")]
        [System.String]$Userid,
        [Parameter(Mandatory=$true, HelpMessage="New ")]
        [System.String]$newPassword
    )
    $Body = @{
        user_password = $newPassword        
    } | ConvertTo-Json
    try{
        $query = "?sysparm_input_display_value=true"
        $uri = "$api/table/sys_user/$Userid$query" 
        Invoke-RestMethod -Method Put -Uri $uri -Headers $Headers -Body $Body
    }
    catch {
        $err = $_
        Write-Log -ErrorLevel 0 -Message "Reset Password Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
  
   
}
#endregion

#Region Main Process
try {
    
    $token = (Get-BearerToken -Url $tokenUrl -privUsername $privUsername -privPassword $privPassword -Scope $scope -clientId $clientId -clientSecret $clientSecret )
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
        "Content-Type" = "application/json"
    }
    
    $userid = Get-ServiceNowUserInfo -Username $username  
    $result = Reset-SNowPassword -Userid $userid -newPassword $password
    Write-Log -ErrorLevel 0 -Message "Password Successfully Changed"
}
catch {
    $err = $_
    Write-Log -ErrorLevel 0 -Message "Reset Password Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 

}
#endregion