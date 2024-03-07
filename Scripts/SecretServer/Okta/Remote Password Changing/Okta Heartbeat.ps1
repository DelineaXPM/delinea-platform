
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Expected Args = @($[1]$tenant-url $username $newpassword ) 


#region define variables
#Define Argument Variables
[string]$tenantUrl = $args[0]
[string]$api = "https://$tenantUrl/api/v1"
[string]$userid = $args[1]
[string]$password = $args[2]


#Script Constants

[string]$LogFile = "$env:Program Files\Thycotic Software Ltd\Distributed Engine\log\Okta-Integration.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Okta Heartbeat"
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

    }
}
#endregion Error Handling Functions

#region Main Process
try {
    Write-Log -Errorlevel 0 -Message "Attempting Password Verification" 
    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $headers.Add("Content-Type", "application/json")

    $body = @{
    "username" = $userid
    "password" = $password
    "option" =       @{
        "multiOptionalFactorEnroll" = $true
        "warnBeforePasswordExpired" =$true
        }
    } | ConvertTo-Json -Depth 3
    $url = "$api/authn"
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"
    $result = $response.status
    if ( $result -eq "SUCCESS")
    {
        $validation = "Credentials are Valid" 
    }

} 
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Username or Password is invalid"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
#endregion Main Process
Write-Log -Errorlevel 0 -Message "Credentials are Valid" 
return $validation
