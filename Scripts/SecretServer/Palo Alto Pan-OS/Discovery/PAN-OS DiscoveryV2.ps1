
#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1] + "/api"
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
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\PAN-OS-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "PAN-OS Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceGroupUserList = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:authenticationProfileList = New-Object System.Collections.ArrayList
#endregion

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

#Region ConverFrom-XML
function ConvertFrom-Xml {
    param([parameter(Mandatory, ValueFromPipeline)] [System.Xml.XmlNode] $node)
    process {
      if ($node.DocumentElement) { $node = $node.DocumentElement }
      $oht = [ordered] @{}
      $name = $node.Name
      if ($node.FirstChild -is [system.xml.xmltext]) {
        $oht.$name = $node.FirstChild.InnerText
      } else {
        $oht.$name = New-Object System.Collections.ArrayList 
        foreach ($child in $node.ChildNodes) {
          $null = $oht.$name.Add((ConvertFrom-Xml $child))
        }
      }
      $oht
    }
  }
  #endregion

function Get-AuthenticationProfiles {
    try {
        $type = "config"
        $action = "get"
        $xpath = "/config/shared/authentication-profile"
    


        # Specify endpoint uri for Users
        $uri = $baseURL +"/?type=" + $type + "&action=" + $action +"&Key=" + $accessToken + "&xpath=" + $xpath 

        Write-Log -Errorlevel 0 -Message "Requesting List of Authenticaiton Profiles form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $pwdObj = Invoke-WebRequest -Method $method -Uri $uri
        $authProfiles = ([xml]$pwdObj.Content).response.result.'authentication-profile'
        return $authProfiles
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
}

function Get-LocalAuthenticationProfiles {
    #Retrieve XML document of All Authentication Profiles
    $authProfilesXML = Get-AuthenticationProfiles

    #Convert XML into Array of Arrays
    $authProfiles =  $authProfilesXML | ConvertFrom-Xml
    foreach ($authProfile in $authProfiles.'authentication-profile') {
        #Identify each Auth Profiles Type
        $authProfileName = $authProfile.Keys
        $type = $authProfile."$authProfileName".method
        #Check to see if Auth Profile Type is a Local Type
        if (($type.keys -eq "local-database") -or ($type.keys -eq "none")) {
            Write-Log 0 -Message "Found Local Auth Profile - $authProfileName"
            [void]$global:authenticationProfileList.add($authProfileName)
        }
    }
}


 function RetrieveUsers {
    try {
        $type = "config"
        $action = "get"
        $xpath = "/config/mgt-config/users"
    


        # Specify endpoint uri for Users
        $uri = $baseURL +"/?type=" + $type + "&action=" + $action +"&Key=" + $accessToken + "&xpath=" + $xpath 

        Write-Log -Errorlevel 0 -Message "Requesting List of Users form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $usersObj = Invoke-WebRequest -Method $method -Uri $uri
        $users = ([xml]$usersObj.Content).response.result.'users'
        return $users
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
   
 }

 function Get-Groups {
    try {
        $type = "config"
        $action = "get"
        $xpath = "/config/shared/local-user-database/user-group"
    


        # Specify endpoint uri for Users
        $uri = $baseURL +"/?type=" + $type + "&action=" + $action +"&Key=" + $accessToken + "&xpath=" + $xpath 

        Write-Log -Errorlevel 0 -Message "Requesting List of Groups form endpoint $uri"    

        # Specify HTTP method
        $method = "get"

        # Send HTTP request
        $groupsObj = Invoke-WebRequest -Method $method -Uri $uri
        $groups = ([xml]$groupsObj.Content).response.result.'user-group'
        return $groups
        } catch {
            $Err = $_    
            Write-Log -ErrorLevel 0 -Message "Failed to Update Password"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
}
 
 
 
 function BuildServiceGroupUserList {

    #Create Array of Service Groups
    $svcGroupsArray = $svcGroups.split(",")

    #Build List of Groups
    $groupsList = Get-Groups
    $groupNameArray = $groupsList.'entry' | Select-object Name -ExpandProperty Name
    $groupMemberArray =  $groupsList.'entry'.user  | Select-object
    $index = 0
    while ($index -lt $groupNameArray.Length) {
        $groupName = $groupNameArray[$index]
        if ($groupName -in $svcGroupsArray) {
            $groupMembersXML = $groupMemberArray[$index]
            foreach ($member in $groupMembersXML.'member') {
                [void]$global:serviceGroupUserList.Add($member.'#text')
            }
        }
        $index = $index + 1
    }    
}



 function isLocalAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$AuthProfileId    
    )

    try
        {
            foreach ($aProfile in  $global:authenticationProfileList)
            { 
                if($aProfile -eq $AuthProfileId)
                {
                    $isLocalAccount = $true
                    return $isLocalAccount
                } 
                else
                {
                    $isLocalAccount = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isLocalAccount  
}


 function isSvcAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
    )

    try
        {
            
    
            foreach ($svcAcctUser in $global:serviceGroupUserList)
            { 
                if($svcAcctUser.Id -eq $userId)
                {
                    $isSvcAcct = $true
                    return $isSvcAcct
                } 
                else
                {
                    $isSvcAcct = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isSvcAcct  
}


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
    throw "PAN-OS Authentication has failed for username - $username" 
}
#endregion


#region Build Local Authenticaiton Profile List
Get-LocalAuthenticationProfiles
#endregion

#region Build List Group Members
#If Advanced mode is enable we build a List of Members that are in the Service Groups provided by the User
if ($DiscoveryMode -eq "Advanced") {
    BuildServiceGroupUserList
}
#endregion


#region Fetch Users
try {

    $tenantUrl = $baseURL

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
 
    #Traverse though the list of Users in the system and determine if they are Privileged Accounts

    #Retrieve XML Document of Users
    $usersList = RetrieveUsers -cursor $nextURL

    #Create Arrays of important fields for each User
    #Each index of the array is related to a specific user
    $uNameArray = $usersList.entry | Select-object Name -ExpandProperty Name
    $uAuthProfileArray = $usersList.entry.'authentication-profile'
    $uSuperUserArray = $usersList.entry.permissions.'role-based'.superuser
    



    #Loop through Arrays 
    $index = 0
    while ($index -lt $uNameArray.Count) {
        #Reset isFound variable for each increment
        $isFound = $false
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
        $object | Add-Member -MemberType NoteProperty -Name username -Value $uNameArray[$index]

        if ($DiscoveryMode -eq "Advanced") {
            #Check for Local User
            if (($null -eq $uAuthProfileArray[$index]) -or (isLocalAccount -AuthProfileId $uAuthProfileArray[$index])) {
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value "True"
                $isFound = $true
            } else {
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value "False"
                $isFound = $true
            }
            #Check for Administrator (SuperUser)
            if ($uSuperUserArray[$index] -eq "yes") {
                $object | Add-Member -MemberType NoteProperty -Name Administrator-Account -Value "True"
                $isFound = $true
            } else {
                $object | Add-Member -MemberType NoteProperty -Name Administrator-Account -Value "False"
            }
            #Check to see if User is a Service Account
            if (isSvcAccount -userId $uNameArray[$index]) {
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value "True"
                $isFound = $true
            } else {
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value "False"
            }

        }
        $index = $index + 1
        #If Account is what we are looking for add to Array
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