
#region define variables
#Define Argument Variables

try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1]
    [string]$clientId = $args[2]
    [string]$clientSecret = $args[3]
    [string]$username = $args[4]
    [string]$password = $args[5]
    [string]$federationDomains = $args[6]
    [string]$svcGroups = $args[7]    
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}




#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ShareFile-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "ShareFile Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceGroupUserList = New-Object System.Collections.ArrayList
[string] $tokenHeader = "Bearer"
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
Write-Log -ErrorLevel 0 -Message "Discovery found $users_found  Accounts"

#region Get All Users
 #Create Headers

 function RetrieveUsers {

    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Specify endpoint uri for Users
        $uri = "$global:apiURL/Accounts/Employees"

        Write-Log -Errorlevel 0 -Message "Requesting Users form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $userObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $userObj
 }

 function RetrieveGroupMembers {
    param(
        [string] $groupId
    )
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Specify endpoint uri for Users
        $uri = "$global:apiURL/Groups($groupId)/Contacts"

        Write-Log -Errorlevel 0 -Message "Requesting Group Contacts form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $groupMembersObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Groups Members List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $groupMembersObj
 }

 function BuildServiceGroupUserList {

    #Querying Groups
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Specify endpoint uri for Users
        $uri = "$global:apiURL/Groups"

        Write-Log -Errorlevel 0 -Message "Requesting Group Contacts form endpoint $uri"    
    
        # Specify HTTP method
        $method = "get"
    
        # Send HTTP request
        $groupsObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    }
    
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Groups Members List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }


    try {
        #Split values in String into Array of Groups
        $svcGroupsArray = $svcGroups.split(",")

        $groups = $groupsObj.value
        foreach ($group in $groups) {
            if ($group.Name -in $svcGroupsArray) {
                #Group is a Service Account
                $groupContactsObj = RetrieveGroupMembers -groupId $group.Id
                foreach ($contact in $groupContactsObj.value) {
                    [void] $global:serviceGroupUserList.add($contact)
                }
            }
        }
        
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to Building Groups Members List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
 }

function isAdminAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            $headers = @{
                "Authorization" = "$tokenHeader $accessToken"    
            }
             
            # Specify endpoint uri for Users
            $uri = "$global:apiURL/Users($userId)"
        
            Write-Log -Errorlevel 0 -Message "Requesting User detail form endpoint $uri"    
            
            # Specify HTTP method
            $method = "get"
            
            # Send HTTP request
            $userObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
            

                if($true -eq $userObj.isAdministrator)
                {
                    $isAdmin = $true
                    return $isAdmin
                } 
                else
                {
                    $isAdmin = $false
                }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isAdmin
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
#endregion

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
    $global:accessToken = $authObj.access_token
    $global:apiURL = "https://" + $authObj.subdomain + "." + $authObj.apicp + "/sf/v3"


}
catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion


#Main Region
#Check Advanced features: Build ArrayList of Users that belong to the specified teams.

#Advanced Group Fetch Region
try {
    if ($DiscoveryMode -eq "Advanced") {
    
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        ##Create Roles Array
        #BuildServiceGroupUserList
        BuildServiceGroupUserList
    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Build Service Group User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
 

#Fetch Users Region
try {

    $tenantUrl = $baseURL

    #region Build User List
    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
 
    #Traverse though the list of Users in the system and determine if they are Privileged Accounts
    $usersList = RetrieveUsers
    foreach ($user in $usersList.value) {
            #Reset isFound variable for each increment
            $isFound = $false
            # All accounts get added to ArrayList because they are all local accounts
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
            $object | Add-Member -MemberType NoteProperty -Name username -Value $user.Email
            $emailDomain = $user.Email.Split('@')[1]
            $federationDomainsArray =$federationDomains.Split(',')
            if ($emailDomain -in $federationDomainsArray) {

                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                } 

            } else {
                $isFound = $true
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                }
            }

            if ($DiscoveryMode -eq "Advanced") {

                #Check for Account Admins
                if  (isAdminAccount -userId $user.Id) {
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true
                    $isFound = $true
                } else {
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
                }
                #Check is Account is Service Account
                if (isSvcAccount -userId $user.Id) {
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
                    $isFound = $true
                } else {
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false
                }
            }

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
#end region

#endregion Main Process
return $adminAccounts


