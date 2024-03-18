

#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1] + "/wapi/v2.7"
    [string]$privUsername = $args[2]
    [string]$privPassword = $args[3]
    [string]$svcGroups = $args[4]
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables


#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Infoblox-Discovery.log"
[string]$LogFile = "c:\temp\Infoblox-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Infoblox Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceGroupList = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:AdminGroupList = New-Object System.Collections.ArrayList
[string]$authTokenType = "Basic"
#endregion

# This section allows the Invoke-WebRequests to ignore Self-Signe Certficates in PowerShell V5
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

#REST Request to Retreive Groups (AdminGroups)
function Get-AdminGroups {
    try {
        $returnFields = "name,superuser,disable"

        $headers = @{
            "Authorization" = "$authTokenType $global:B64encodeToken"    
        }

        # Specify endpoint uri for AdminGroups
        $uri = $baseURL +"/admingroup?_return_fields=$returnFields"

        Write-Log -Errorlevel 0 -Message "Requesting List of Groups form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $groupObj = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
        return $groupObj
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to List AdminGroups"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
}

#REST Request retrieves list of Users
 function Get-AdminUsers {
    try {
        $returnFields = "name,admin_groups,auth_type,disable"

        $headers = @{
            "Authorization" = "$authTokenType $global:B64encodeToken"    
        }

        # Specify endpoint uri for Users
        $uri = $baseURL +"/adminuser?_return_fields=$returnFields"

        Write-Log -Errorlevel 0 -Message "Requesting List of Users form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $usersObj = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
        return $usersObj
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to List Users"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
   
 }

 #Function to Loop through and build an Array List of Admin and Service Account Groups
 function buildGroupList {

    #Split values in String into Array of Groups
    $svcGroupsArray = $svcGroups.split(",")

    $groups = Get-AdminGroups
    foreach ($group in $groups) {
        #Check to see if Group is disabled
        if ($group.disable -ne "false") {
            #Check to see if Group is SuperUser/Admin
            if ($group.superuser -eq "true") {
                [void] $global:AdminGroupList.Add($group)
            }
            #Check to see if Group is in User-Defined Service Group List
            if (($group.name) -in $svcGroupsArray) {
                [void] $global:serviceGroupList.Add($group)
            }
        }
    }

 }


 #Function to see if the User is an Admin based on thier Groups
function isAdmin {
param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [Array]$userGroups   
)   

    #Loop through each Admin Group
    foreach ($group in $global:AdminGroupList) {
        #Loop through each of the User's groups
        foreach ($userGroup in $userGroups) {
            #Check to see if the AdminGroup and User Group name is the same
            if ($group.name -eq $userGroup) {
                return $true
            }
        }
        
    }
    return $false
}

#Fuction to see if the User is a Service Account based on their Groups
function isSvcAccount {
param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$groupName   
)
    #Loop through each User-Defined Service Account Group
    foreach ($group in $global:serviceGroupList) {
        #Validate the Service Account Group with the User Group name passed into function
        if ($groupName -eq $group.name) {
            return $true
        }
    }
    
    return $false
}
#Creating an Authentication Token for use with API requests
#region Build Infoblox Auth Token
try {

    #Create Authorization Token
    #Auth requires a Base64 encoded string using Privleged Account Username & Password
    $nonEncodeStr = $privUsername + ":" + $privPassword
    $bytes =  [System.Text.Encoding]::UTF8.GetBytes($nonEncodeStr)
    $global:B64encodeToken = [Convert]::ToBase64String($bytes)   
}
catch {
    $Err = $_   
    throw "Error building Basic Authentication Token" 
}
#endregion

#Build Admin and Service Groups Lists if Advanced Discovery Mode is Enabled
#region Build Group for Admin and Service Account List
if ($DiscoveryMode -eq "Advanced") {
    buildGroupList
}
#endregion

#region Fetch Users
try {

    $tenantUrl = $args[1]

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
 
    #Traverse though the list of Users in the system and determine if they are Privileged Accounts
    #Retrieve XML Document of Users
    #These Users are in the Administrators Section under Devices
    $usersList = Get-AdminUsers
    foreach ($user in $usersList) {
        $isFound = $false
        if ($user.disable -ne "false") {
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
            $object | Add-Member -MemberType NoteProperty -Name username -Value $user.name
            #Check to see if this is a Local Account
            #Auth Types LOCAL or SAML_LOCAL are considered "Local" accounts
            if (($user.auth_type -eq "LOCAL") -or ($user.auth_type -eq "SAML_LOCAL")) {
                $isFound = $true
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value "True"
                } 
            } else {
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value "False"
                } 
            }
            #Check to see if this is an Admin Account or Service Account
            if ($DiscoveryMode -eq "Advanced") {
                #Checking for Admin Account
                if (isAdmin -userGroups ($user.admin_groups)) {
                    $isFound = $true
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value "True"
                } else {
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value "False"
                }

                #Check for Service Account
                foreach ($group in $user.admin_groups) {
                    if (isSvcAccount -groupname $group) {
                        $isFound = $true
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value "True"
                    } else {
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value "False"
                    }
                }
            }
            

        }
        #Flagged Accounts get added to final output Array List
        if ($true -eq $isFound) {
            [void] $adminAccounts.add($object)
        }
        
    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Analyze the Users"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Fetch Users

return $adminAccounts