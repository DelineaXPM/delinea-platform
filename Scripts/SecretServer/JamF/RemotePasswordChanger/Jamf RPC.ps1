[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region Set Paramaters and Variables
[string]$baseURL = $args[0]
[string]$Username = $args[1]
[string]$newpassword = $args[2]
[string]$clientId = $args[3]
[string]$clientSecret = $args[4]
[string]$tokenUrl = "$baseURL/api/oauth/token"
[string]$classicapi = "$baseURL/JSSResource"

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Jamf-Password_Rotate.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Jamf Password Change"
#endregion

#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0, 1, 2, 3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message
    )
    #evaluate Log Level based on global configuration
    if ($ErrorLevel -le $LogLevel) {
        #format message
        [string]$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm:sszzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        #write log data
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel, $logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
       
    }
}
#endregion Error Handling Functions

#region Get Access Token
#get access token
function Get-BearerToken {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Token URL to generate access token")]
        [System.String]$tokenURL,
        [Parameter(Mandatory = $true, HelpMessage = "client_id")]
        [System.String]$clientId,
        [Parameter(Mandatory = $true, HelpMessage = "client_secret")]
        [System.String]$clientSecret
    )
    try {
        Write-Log -Errorlevel 0 -Message "Obtaining Access Token"
        #prepare body for the token request
        $headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
        }
   
        $body = @{
            grant_type    = "client_credentials"
            client_id     = $clientId
            client_secret = $clientSecret
        }
        #make a POST request to obtain the token
        $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -Headers $headers

        #extract the access token from the response
        $accessToken = $response.access_token
        Write-Log -Errorlevel 0 -Message "Access Token Successfully Obtained"
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Obtaining Jamf Access Token failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $accessToken
}
#endregion Get Access Token

#region RPC Funtions
function get-JamfUserInfo {
    param (
        [Parameter(mandatory = $true, HelpMessage = "Username to check PW")]
        [system.string]$Username,
        [Parameter(mandatory = $true, HelpMessage = "Access Token")]
        [system.string]$accessToken
    )
    $headers = @{
        "Content-Type"  = "application/xml"
        "Authorization" = "Bearer $accesstoken"
    }
    try {
        $uri = "$classicapi/accounts/username/$username" 
        $user = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        if ($user.account.name -eq $username) {
            $userid = $user.account.id
        }
    }
    catch {
        $err = $_
        Write-Log -ErrorLevel 0 -Message "Retrieving Jamf UserID  Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $userid
}

function Reset-JamfPassword {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Target User ID")]
        [System.String]$userid,
        [Parameter(Mandatory = $true, HelpMessage = "New Password")]
        [System.String]$newPassword,
        [Parameter(mandatory = $true, HelpMessage = "Access Token")]
        [system.string]$accessToken
    )
    $headers = @{
        "Content-Type"  = "application/xml"
        "Authorization" = "Bearer $accesstoken"
    }
    
    [xml]$xmlbody = [xml]"
    <account>
        <password>$newpassword</password>
    </account>
    "
    try {
        $uri = "$classicapi/accounts/userid/$userid"
        Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $xmlBody
    }
    catch {
        $err = $_
        Write-Log -ErrorLevel 0 -Message "Reset Password Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
}
#endregion
#region main process
try {
    $accessToken = Get-BearerToken -tokenURL $tokenUrl -clientId $clientId -clientSecret $clientSecret
    $userid = get-JamfUserInfo -Username $Username -accessToken $accessToken
    $result = Reset-JamfPassword -userid $userid -newPassword $newpassword -accessToken $accessToken
    Write-Log -ErrorLevel 0 -Message "Password Successfully Changed"
}
catch {
    $err = $_
    Write-Log -ErrorLevel 0 -Message "Reset Password Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
#endregion