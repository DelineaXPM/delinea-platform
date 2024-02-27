[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#region Set Paramaters and Variables
[string]$baseURL = $args[0]
[string]$Username = $args[1]
[string]$Password = $args[2]
[string]$tokenUrl = "$baseURL/api/v1/auth/token"
#script Constants
[string]$logApplicationHeader = "Jamf Heartbeat"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Jamf-Password_Rotate.log"
[int32]$LogLevel = 3

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

#region Get Token
function Get-BearerToken {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Heartbeat User Name")]
        [System.String]$Username,
        [Parameter(Mandatory = $true, HelpMessage = "Heartbeat User Password")]
        [System.String]$password,
        [Parameter(Mandatory = $true, HelpMessage = "Root Url to hit to get bearer token")]
        [System.String]$Url
      
    )
    #convert Heartbeat credentials to Basic Auth Base64 String
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
        Accept        = "application/json"
    }
    try {
        Write-Log -ErrorLevel 0 -Message "Attempting User Heartbeat"
        $result = Invoke-RestMethod -Method Post -Uri $Url -Headers $headers
        $token = $result.token
        Write-Log -ErrorLevel 0 -Message "Heartbeat Successful"
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Heartbeat Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $token
}
#endregion
$result = Get-BearerToken -Url $tokenUrl -Username $Username -password $Password