
#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1] + "/2.0"
    [string]$accesstoken = $args[2]
    [string]$federationDomains = $args[3]   
    [string]$svcGroups = $args[4]
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}


#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\SmartSheet-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "SmartSheet Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceGroupUserList = New-Object System.Collections.ArrayList
[string] $tokenHeader = "Bearer"
[string]$pageSize = 100 #Max Size is 100
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


#region Get All Users
# API Call to request List of Users

 function RetrieveUsers {
    param(
        [string] $cursor
    )
    try {
   
        $headers = @{
             "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseURL + "/users"      
        
        # Specify endpoint uri for Users
        if ("" -eq ($cursor)) {
            $uri = $uri + "?pageSize=$pageSize"
        } else {
            $uri = $uri + "?page=$cursor&pageSize=$pageSize"
        }

        Write-Log -Errorlevel 3 -Message "Requesting Users form endpoint $uri"    
    
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
 #endregion Get All Users

 #region Get Group Members
 # Api to gather Group Details including Members
 function RetrieveGroupMembers {
    param(
        [string] $groupId,
        [string] $cursor

    )

    try {
   
        $headers = @{
           "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Specify endpoint uri for Users
        $uri = "$baseURL/groups/$groupId"

        Write-Log -Errorlevel 3 -Message "Requesting Group Members form endpoint $uri"    
    
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
 #endregion Get Group Members

#region Get Groups
# API call to retreieve List of Groups
 function RetrieveGroups {
    param(
        [string] $cursor
    )

#Querying Groups
    try {
    
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
    
        # Specify endpoint uri for Users
        $uri = "$baseURL/groups"

        if ("" -eq ($cursor)) {
            $uri = $uri + "?pageSize=$pageSize"
        } else {
            $uri = $uri + "?page=$cursor&pageSize=$pageSize"
        }

        Write-Log -Errorlevel 3 -Message "Requesting Group form endpoint $uri"    

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
    return $groupsObj
}
#endregion Get Groups
 
 
 #region Build Service Account List
 # Function Builds List of Service Accounts by looping through User defined Groups
 function BuildServiceGroupUserList {

    try {
        #Split values in String into Array of Groups
        $svcGroupsArray = $svcGroups.split(",")

        $moreGroups = $true
        $cursor = $null
        while ($true -eq $moreGroups) {
            $groupList = RetrieveGroups -cursor $cursor
            $groups = $groupList.data
            foreach ($group in $groups) {
                if ($group.Name -in $svcGroupsArray) {
                    #Group is a Service Account
                    $groupMembersObj = RetrieveGroupMembers -groupId $group.Id
                    foreach ($member in $groupMembersObj.members) {
                        if ($false -eq (isSvcAccount -userId $member.email)) {
                            [void] $global:serviceGroupUserList.add($member)
                        }
                        
                    }
                }
            }
            #Check to see if there are more Groups
            $cursor = $groupList.pageNumber
            $totalPages = $groupList.totalPages
            if ($cursor -lt $totalPages) {
                $moreGroups = $true
                $cursor = $cursor + 1
            } else {
                $moreGroups = $false
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
 #endregion Build Service Account List


#region Validate Service Account
# Check to see if User Id exists in Service Account List
 function isSvcAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
    )

    try
        {
            $isSvcAcct = $false
    
            foreach ($svcAcctUser in $global:serviceGroupUserList)
            { 
                if($svcAcctUser.email -eq $userId)
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
#endregion Validate Service Account

#region Advanced Group Fetch
#Check Advanced features: Build ArrayList of Service Accounts that belong to the specified Group.
try {
    if ($DiscoveryMode -eq "Advanced") {
    
        Write-Log -Errorlevel 3 -Message "Retrieving  List of Service Account Users"       
        ##Create List of Users that are in Service Groups
        BuildServiceGroupUserList
    }
} catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to Build Service Group User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Advanced Group Fetch


#Region Main Process
$tenantUrl = $args[1]
$more = $true
$cursor = $null
while ($true -eq $more) {
    $userListObj = RetrieveUsers -cursor $cursor
    foreach ($user in $userListObj.data) {
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
        $object | Add-Member -MemberType NoteProperty -Name username -Value $user.Email
        #Check to see if the Account is a local account based on the Email address and Federation Domains
        $emailDomain = $user.email.Split('@')[1]
        $federationDomainsArray =$federationDomains.Split(',')
        if ($emailDomain -in $federationDomainsArray) {
            if ($DiscoveryMode -eq "Advanced") {
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
            } else {
                $isFound = $true
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                }
            }
        } else {

            if ($DiscoveryMode -eq "Advanced") {
                $isFound = $true
                $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
            } else {
                if ($DiscoveryMode -eq "Advanced") {
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                }
            }
        }
        #Check for Admin and Service Accounts
        if ($DiscoveryMode -eq "Advanced") {
             #Check for Account Admins
            if  ("true" -eq $user.admin) {
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true
                $isFound = $true
            } else {
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
            }
            #Check is Account is Service Account
            if (isSvcAccount -userId $user.email) {
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
                $isFound = $true
            } else {
                $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false
            }
        }
        if ($true -eq $isFound ) {
            [void] $adminAccounts.add($object)
        }
    }
    $cursor = $userListObj.pageNumber
    $totalPages = $userListObj.totalPages
    if ($cursor -lt $totalPages) {
        $more = $true
        $cursor = $cursor + 1
    } else {
        $more = $false
    }


}
return $adminAccounts
#endregion Main Process

