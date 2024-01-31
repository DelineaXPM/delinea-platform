
#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1] + "/v2"
    [string]$accountId = $args[2]
    [string]$clientId = $args[3]
    [string]$clientSecret = $args[4]
    [string]$federationDomains = $args[5]
    [string]$svcGroups = $args[6]    
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}
#endregion define variables


#region Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Zoom-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Zoom Discovery"
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceGroupUserList = New-Object System.Collections.ArrayList
[string] $tokenHeader = "Bearer"
[string] $pageSize = 2 #Max Page Size is 300
#Zoom Auth Constants
[string] $zoomAuthUrl = "https://zoom.us/oauth/token"
[string] $zoomAuthHeader = "Basic"
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




 function RetrieveUsers {
    param(
        [string] $cursor
    )

    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Specify endpoint uri for Users
        $uri = "$baseURL/users"

        if ("" -eq $cursor) {
            $uri = $uri + "?page_size=$pageSize"
        } else {
            $uri = $uri + "?page_size=$pageSize&next_page_token=$cursor"
        }

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
        [string] $groupId,
        [string] $cursor

    )

    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        
        # Specify endpoint uri for Users
        $uri = "$baseURL/groups/$groupId/members"

        if ("" -eq $cursor) {
            $uri = $uri + "?limit=$pageSize"
        } else {
            $uri = $uri + "?page_size=$pageSize&next_page_token=$cursor"
        }
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

 function RetrieveGroups {


#Querying Groups
    try {
    
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
    
        # Specify endpoint uri for Users
        $uri = "$baseURL/groups"
        

        Write-Log -Errorlevel 0 -Message "Requesting Group form endpoint $uri"    

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
 
 
 
 function BuildServiceGroupUserList {

    try {
        #Split values in String into Array of Groups
        $svcGroupsArray = $svcGroups.split(",")


            $groupList = RetrieveGroups -cursor $nextURL
            $groups = $groupList.groups
            foreach ($group in $groups) {
                if ($group.Name -in $svcGroupsArray) {
                    #Group is a Service Account
                    $moreGroupMembers = $true
                    $nextURLGroupMembers = $null
                    while ($moreGroupMembers) {
                        $groupMembersObj = RetrieveGroupMembers -groupId $group.Id -cursor $nextURLGroupMembers
                        foreach ($member in $groupMembersObj.members) {
                            [void] $global:serviceGroupUserList.add($member)
                        }
                        #Check to see if there are more Group Members
                        $nextURLGroupMembers = $groupMembersObj.next_page_token
                        if ("" -eq $nextURLGroupMembers) {
                            $moreGroupMembers = $false
                        }
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


#region Obtain Zoom Auth Token
try {

    #Create Authorization Token
    #Auth requires a Base64 encoded string using Client Id and Client Secret
    $nonEncodeStr = $clientId + ":" + $clientSecret
    $bytes =  [System.Text.Encoding]::UTF8.GetBytes($nonEncodeStr)
    $B64encodeToken = [Convert]::ToBase64String($bytes)

    $headers = @{
        "Authorization" = "$zoomAuthHeader $B64encodeToken"    
        "Content-Type" = "application/x-www-form-urlencoded"
    }
     
    $authBody = @{
        "grant_type" = "account_credentials"
        "account_id" = "$accountId"
    }

    # Specify endpoint uri for Users
    $uri = $zoomAuthUrl

    Write-Log -Errorlevel 0 -Message "Requesting Access Token form endpoint $uri"    

    # Specify HTTP method
    $method = "post"

    # Send HTTP request
    $authObj = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri -Body $authBody
    $accessToken = $authObj.access_token

    
}
catch {
    $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to obtian Authentication Token"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
}
#endregion


#Check Advanced features: Build ArrayList of Users that belong to the specified Group.

#region Advanced Group Fetch
try {
    if ($DiscoveryMode -eq "Advanced") {
    
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
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
 

#region Fetch Users
try {

    $tenantUrl = $baseURL

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
 
    #Traverse though the list of Users in the system and determine if they are Privileged Accounts

    $moreUsers = $true
    $nextURL = $null
    while ($true -eq $moreUsers) {
        $usersList = RetrieveUsers -cursor $nextURL
        foreach ($user in $usersList.users) {
            #Check to see if account is Active and Verfied
            if (("active" -eq $user.status) -and (1 -eq $user.verified)) {
                #Reset isFound variable for each increment
                $isFound = $false
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
                $object | Add-Member -MemberType NoteProperty -Name username -Value $user.Email
                $emailDomain = $user.Email.Split('@')[1]
                $federationDomainsArray =$federationDomains.Split(',')
                #Check to see if Account is a Local Account
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
                    if  (( "0" -eq $user.role_id) -or ("1" -eq $user.role_id)) {
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
            #Check for more User records
            $nextURL = $usersList.next_page_token
            if ("" -eq $nextURL) {
                $moreUsers = $false
            }
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