
#region define variables
#Define Argument Variables
try {

    [string]$baseURL = $args[0]
    [string]$privUsername = $args[1]
    [string]$privPassword = $args[2]
    [string]$Username = $args[3]
    [string]$Password = $args[4]
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables


#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Infoblox-RPC.log"
[string]$LogFile = "c:\temp\Infoblox-RPC.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Infoblox RPC"
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

    }
}
#endregion Error Handling Functions


#REST Request that updates User's password using the Privleged Accounts credentials
#region Set-AdminUser
function Set-AdminUser {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$refUrl,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$privUserToken
    )
    try {
        #JSON Body with Fields to be Updated
        $body = @{
            "password" = $Password
        } | ConvertTo-Json

        #Headers
        $headers = @{
            "Authorization" = "$authTokenType $privUserToken" 
            "Content-Type" = "application/json"
            "Host" = $baseUrl.Substring(8)
            "Content-Length" = $body.length
        }

        # Specify endpoint uri for Users
        $uri = $apiUrl + "/" + $refUrl

        Write-Log -Errorlevel 0 -Message "Updating Password form endpoint $uri"    

        # Specify HTTP method
        $method = "put"

        # Send HTTP request
        $pwdObj = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -Body $body
        return $pwdObj
        } 
        catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to update Password"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
   
 }
#endregion Set-AdminUser

#Getting Reference Link to User to be used in Password Update API Request
#region Get-AdminUser
function Get-AdminUser {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userToken  
    )
    try {
        $returnFields = "name"

        $headers = @{
            "Authorization" = "$authTokenType $userToken"    
        }

        # Specify endpoint uri for Users
        $uri = $apiUrl +"/adminuser?_return_fields=$returnFields&name:=$username"

        Write-Log -Errorlevel 0 -Message "Requesting UserProfile form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $usersObj = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
        
        return $usersObj
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to request adminUser"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
   
 }
#endregion Get-AdminUser


 
#Creating an Authentication Token for use with API requests
#region Build Infoblox Auth Token
try {

    #Create Authorization Token
    #Auth requires a Base64 encoded string using Username and Password
    $nonEncodeStr = $privUsername + ":" + $privPassword
    $bytes =  [System.Text.Encoding]::UTF8.GetBytes($nonEncodeStr)
    $B64encodePrivUserToken = [Convert]::ToBase64String($bytes)  
}
catch {
    $Err = $_   
    throw "Error building Basic Authentication Token" 
}
#endregion Build Infoblox Auth Token


#region Main
try {

    Write-Log -Errorlevel 0 -Message "Attempting to RPC"    

    $user = Get-AdminUser -userToken $B64encodePrivUserToken
    $resultObj = Set-AdminUser -privUserToken $B64encodePrivUserToken -refUrl ($user._ref)
    if ($null -ne $resultObj) {
        return "Password Update Successful"
    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Main
