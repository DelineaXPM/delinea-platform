

#region define variables
#Define Argument Variables
try {

    [string]$baseURL = $args[0]
    [string]$clientId = $args[1]
    [string]$clientSecret = $args[2]
    [string]$username = $args[3]
    [string]$password = $args[4]  
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}




#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ShareFile-Heartbeat.log"
[string]$LogFile = "c:\temp\ShareFile-Heartbeat.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "ShareFile Heartbeat"
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


#Region Authentication 
try {

    #Set Headers
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"    
    }

    #Set Body (Auth Parameters)
    $body = @{
        "grant_type" = "password"
        "client_id" = $clientId
        "client_secret" = $clientSecret
        "username" = $username
        "password" = $password
    }   
     
    # Get full URL from baseUris
    $uri = $baseURL + "/oauth/token"
 

    Write-Log -Errorlevel 0 -Message "Requesting AuthToken form endpoint $uri"    
    
    # Specify HTTP method
    $method = "get"
    
    # Send HTTP request
    $authObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri -Body $body
    $accessToken = $authObj.access_token

    if ($null -ne $accessToken) {
        $validation = "Credentials are Valid" 
    } 
}
catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Authenticate User"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw "$Err.Exception args: $args" 
} 
#endregion

return $validation



