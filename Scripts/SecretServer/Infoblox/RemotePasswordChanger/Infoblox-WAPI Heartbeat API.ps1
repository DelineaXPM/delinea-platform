
#region define variables
#Define Argument Variables
try {

    [string]$baseURL = $args[0] 
    [string]$Username = $args[1]
    [string]$Password = $args[2]
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables


#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Infoblox-Heartbeat.log"
[string]$LogFile = "c:\temp\Infoblox-Heartbeat.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Infoblox Heartbeat"
[string]$authTokenType = "Basic"
[string]$apiUrl = $baseURL + "/wapi/v2.7"
#endregion

# This section allows the Invoke-RESTMethod to ignore Self-Signe Certficates in PowerShell V5
#region Ignore Self-Signed Certificates
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
#endregion Ignore Self-Signed Certificates

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
        $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}
#endregion Error Handling Functions


#REST Request retrieves UserProfile for Current User
#region Get-UserProfile
 function Get-UserProfile {
    try {
        $returnFields = "name,user_type"

        $headers = @{
            "Authorization" = "$authTokenType $global:B64encodeToken"    
        }

        # Specify endpoint uri for UserProfile
        $uri = $apiUrl +"/userprofile?_return_fields=$returnFields"

        Write-Log -Errorlevel 0 -Message "Requesting UserProfile form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $usersObj = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
        return $usersObj
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to request UserProfile"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
   
 }
#endregion Get-UserProfile


 
#Creating an Authentication Token for use with API requests
#region Build Infoblox Auth Token
try {

    #Create Authorization Token
    #Auth requires a Base64 encoded string using Username and Password
    $nonEncodeStr = $Username + ":" + $Password
    $bytes =  [System.Text.Encoding]::UTF8.GetBytes($nonEncodeStr)
    $global:B64encodeToken = [Convert]::ToBase64String($bytes)   
}
catch {
    $Err = $_   
    throw "Error building Basic Authentication Token" 
}
#endregion Build Infoblox Auth Token


#region Authenticate
try {

    Write-Log -Errorlevel 0 -Message "Attempting API Call..."    

    $uprofile = Get-UserProfile
    if ($null -ne $uprofile) {
        return "Authentication Successful"
    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Authenticate User"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Authenticate
