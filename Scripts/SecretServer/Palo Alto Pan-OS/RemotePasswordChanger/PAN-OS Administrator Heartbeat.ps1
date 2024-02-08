
#region define variables
#Define Argument Variables
try {

    [string]$baseURL = $args[0] + "/api"
    [string]$username = $args[1]
    [string]$password = $args[2]
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables

#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\PAN-OS-Heartbeat.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "PAN-OS Heartbeat"
#endregion define variables

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

# This section allows the Invoke-WebRequests to ignore Self-Signe Certficates in PowerShell V5
#endregion Error Handling Functions
if (-not("dummy" -as [type])) {
    add-type -TypeDefinition @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }

    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
"@
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()


#Web Request to Retrieve API Access token and validate User's Password
#region Main
try {

    # Specify endpoint uri for Users
    $uri = $baseURL +"/?type=keygen&user=" + $username + "&password=" + $password

    Write-Log -Errorlevel 0 -Message "Validating Credentials form endpoint $uri"    

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $authObj = Invoke-WebRequest -Method $method -Uri $uri
    $content = ($authObj.Content)
    if ($content.Contains("success")) {
        return $true
    } else {
        $Err = $_
        throw "PAN-OS Authentication has failed for username - $username"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
    }
    
}
catch {
    $Err = $_   
    throw "PAN-OS Authentication has failed for username - $username" 
}
#endregion Main