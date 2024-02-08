$args = @("https://192.168.111.129","admin",".eWeek09@","rsmith",".Yahoo09@")

#region define variables
#Define Argument Variables
try {

    [string]$baseURL = $args[0] + "/api"
    [string]$privUsername = $args[1]
    [string]$privPassword = $args[2]
    [string]$username = $args[3]
    [string]$newPassword = $args[4]
    
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables


#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\PAN-OS-RPC.log"
[string]$LogFile = "c:\temp\PAN-OS-RPC.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "PAN-OS RPC"
[int]$commitTimeout = 60 * 5 #5 minutes
#endregion

#region  Ignore Self-Signed Certificates Poweshell V5
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
        $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}
#endregion Error Handling Functions

function Get-CommitStatus {
    $type = "op"
    $cmd = "<show><jobs><id>$jobId</id></jobs></show>"


    # Specify endpoint uri for Users
    $uri = $baseURL +"/?type=" + $type + "&cmd=" + $cmd +"&Key=" + $accessToken

    Write-Log -Errorlevel 0 -Message "Checking Commit Status form endpoint $uri"    

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $jobObj = Invoke-WebRequest -Method $method -Uri $uri
    $status = ($jobObj.Content)

    return $status

}

#Function to commit Password CHhange.  Only the changes the Privleged Users submits get Commited
#Privleged User should only be used for Deliena RPC and no other PAN-OS changes 
function Invoke-Commit {
    try {

        $jobId = $null
        $type = "commit"
        $cmd = "<commit><partial><admin>$privUsername</admin></partial></commit>"
    
    
        # Specify endpoint uri for Users
        $uri = $baseURL +"/?type=" + $type + "&cmd=" + $cmd +"&Key=" + $accessToken
    
        Write-Log -Errorlevel 0 -Message "Generating Password form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $commitObj = Invoke-WebRequest -Method $method -Uri $uri
        $content = ($commitObj.Content)
        $jobId = ([xml]$content).response.result.job
        
        if ($null -ne $jobId) {
            $isPending = $true
            $timeWaited = 0
            while ($true -eq $isPending)  {
                $commitStatus = Get-CommitStatus -jobId $jobId
                if ($commitStatus.Contains("PEND")){
                    Write-Log -ErrorLevel 0 -Message "Sleeping for 10 Seconds"
                    Start-Sleep -Seconds 10
                    $timeWaited = $timeWaited +10
                    if ($timeWaited -gt $commitTimeout) {
                        throw "PAN-OS Commit Timed Out.  Please check with PAN-OS Administrator." 
                    }
                } else {
                    $isPending = $false
                }
            }
        }
    } catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $true
}

#Obtain Access Token for API calls
#region Obtain PAN-OS Auth Token
try {

    # Specify endpoint uri for Users
    $uri = $baseURL +"/?type=keygen&user=" + $privUsername + "&password=" + $privPassword

    Write-Log -Errorlevel 0 -Message "Validating Credentials form endpoint $uri"    

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $authObj = Invoke-WebRequest -Method $method -Uri $uri
    $content = ($authObj.Content)
    $accessToken = ([xml]$content).response.result.key
    
}
catch {
    $Err = $_ 
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw "PAN-OS Authentication has failed for username - $username" 
}
#endregion

#region Creat Password Hash
#PAN-OS requires that you use a Hash in order to set a Password.
#This Region will run the API calls to obtain this hash.
try {
    $type = "op"
    $cmd = "<request><password-hash><password>$newPassword</password></password-hash></request>"


    # Specify endpoint uri for Users
    $uri = $baseURL +"/?type=" + $type + "&cmd=" + $cmd +"&Key=" + $accessToken

    Write-Log -Errorlevel 0 -Message "Generating Password form endpoint $uri"    

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $phashObj = Invoke-WebRequest -Method $method -Uri $uri
    $content = ($phashObj.Content)
    $phashNewPassword = ([xml]$content).response.result.phash
    
}
catch {
    $Err = $_   
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw "Failed to Generate PHASH for new password."
}

#endregion

#SOAP Call to Update Password for a user
#region Update Password
try {

    
    $type = "config"
    $action = "edit"
    $xpath = "/config/mgt-config/users/entry[@name='$username']/phash"
    $elememt = "<phash>$phashNewPassword</phash>"


    # Specify endpoint uri for Users
    $uri = $baseURL +"/?type=" + $type + "&action=" + $action +"&Key=" + $accessToken + "&xpath=" + $xpath + "&element=" + $elememt

    Write-Log -Errorlevel 0 -Message "Generating Password form endpoint $uri"    

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $pwdObj = Invoke-WebRequest -Method $method -Uri $uri
    $content = ($pwdObj.Content)
    Write-Log -ErrorLevel 0 -Message "Password Change Response - $content"
    if ($content.Contains("success")) {
        if (Invoke-Commit) {
            Write-Log -Errorlevel 0 -Message "Configuration Commit Successful"
            return "Password Change Successful"
        } else {
            throw "Configuration Commit Failed"
        }

    } else {
        $Err = $_
        Write-Log -ErrorLevel 2 -Message $Err.Exception  
        Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
        throw "Password Update Command Failed"
    }
    

} catch {
    $Err = $_    
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
    throw $Err.Exception
}

return "Password Change Successful"
#endregion Fetch Users