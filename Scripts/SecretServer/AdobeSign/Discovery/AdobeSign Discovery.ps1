$args = @("Default","api.na1.adobesign.com", "3AAABLblqZhDgUgDAXcpI9wbn1uaA0L_EvnsFST0qfWWxyKZOB9R8m6txuMYii2rK9saXwv2RlFRUmA7icf5pYOpO6JK_AXbP","true","ServiceAccounts=CBJCHBCAABAADKXZhgQc1ZiSl3WydXp9KbAFLPdSF4Qm")
#region define variables
#Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$api = "api/rest/v6"
[string]$accesstoken = $args[2]
[string]$pageSize = 100
[boolean]$sAMLEnabled = [System.Convert]::ToBoolean($args[3])
[string]$svcGroupNames = $args[4]

#Script Constants
[string]$LogFile = "$env:Program Files\Thycotic Software Ltd\Distributed Engine\log\AdobeSign-Discovery.log"
[string]$LogFile = "C:\temp\AdobeSign-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Adobe Acrobat Sign Discovery"
[System.Collections.ArrayList]$users = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$adminAccounts = New-Object System.Collections.ArrayList
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


#region Get All Users
 #Create Headers

 function RetrieveUsers {
    param(
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "Bearer $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseUris.apiAccessPoint
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        if ([string]::IsNullOrEmpty($cursor)) {
            $uri = "$uri$api/users?pageSize=$pageSize"
        } else {
            $uri = "$uri$api/users?cursor=$cursor&pageSize=$pageSize"
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


 function RetrieveUserDetail {
    param(
        [Parameter(Mandatory)]
        [string] $userId
    )
    try {
   
        $headers = @{
        "Authorization" = "Bearer $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseUris.apiAccessPoint
        
     
        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        $uri = "$uri$api/users/$userId"

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
 #endregion


#region Service Account Functions

function Get-GroupMembers {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $GroupId,
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "Bearer $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseUris.apiAccessPoint
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        if ([string]::IsNullOrEmpty($cursor)) {
            $uri = "$uri$api/groups/$GroupId/users?pageSize=$pageSize"
        } else {
            $uri = "$uri$api/groups/$GroupId//users?cursor=$cursor&pageSize=$pageSize"
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

function get-svcAccountUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Service Account users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are members of 
    Service Account Groups  are passed in as a comma seperated list of Group Names that Identify Service Account Users.
    
    .EXAMPLE
    An example: Service Team=0ee39126-67d5-4e2c-93cc-a78f32ccc78d
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        ##Create Roles Array
      
        If ($svcGroupNames)
        {
            ### Create Array of Serice Account Groups
            $svcGroupArray = $svcGroupNames.split(",").split("=")[1]
            #Clear Parametwr List
          
           $svcUsers = @()
            
                   
                    foreach($Group in $svcGroupArray )
                    {
                        
                        $more = $true
                        $cursor = $null
                        while ($true -eq $more) {
                            if ($null -eq $cursor) {
                                $results =Get-GroupMembers -GroupId $Group
                            } else {
                                $results =Get-GroupMembers -GroupId $Group -cursor $cursor
                            }

                            foreach ($groupUser in $results) {
                                $svcUsers +=  $groupUser.userInfoList.id
                         
                            }

                            #Check to see if anymore pages of results
                            $pageObj = $userObj.page
                            if ($null -ne $pageObj.curor) {
                                $more = $true
                                $cursor = $pageObj.curor
                            } else {
                                $more =$false
                            }
                        }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcUsers.Count) Service Accounts"    
                

        }   
    
    }
}   
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve admin User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception  
    }
 return $svcUsers
} 

 function isSvcAccount{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            
    
            foreach ($svcAcctUser in $global:svcAccountUsers)
            { 
                if($svcAcctUser -eq $userId)
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

#region Base URIs
 #Create Headers
 try {
   
    $headers = @{
    "Authorization" = "Bearer $accessToken"     
    #"Accept" = "application/json, application/xml"
    #"Content-Type" = "application/json, application/xml"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of URIs"    
    # Get Base URIs
    
    
    # Specify endpoint uri for Users
    $uri = "$baseUrl/$api/baseUris"

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $baseUris = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve baseUris"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion

$tenantUrl = $baseUris.webAccessPoint

#region Build User List
Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
$userObj = RetrieveUsers

$usersList = $userObj.userInfoList
foreach ($user in $usersList) {
    $object = New-Object -TypeName PSObject
    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
    $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.email
    $object | Add-Member -MemberType NoteProperty -Name id -Value $user.id
    $object | Add-Member -MemberType NoteProperty -Name admin -Value $user.isAccountAdmin
    $userDetailobj = RetrieveUserDetail($user.id)
    $object | Add-Member -MemberType NoteProperty -Name accountType -Value $userDetailobj.accountType
    $object | Add-Member -MemberType NoteProperty -Name status -Value $userDetailobj.status
    [void] $users.add($object)
    
}
$pageObj = $userObj.page
while ($null -ne $pageObj.nextCursor) {
    $userObj = RetrieveUsers($pageObj.nextCursor)

    $usersList = $userObj.userInfoList
    foreach ($user in $usersList) {
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
        $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.email
        $object | Add-Member -MemberType NoteProperty -Name id -Value $user.id
        $object | Add-Member -MemberType NoteProperty -Name admin -Value $user.isAccountAdmin
        $userDetailobj = RetrieveUserDetail($user.id)
        $object | Add-Member -MemberType NoteProperty -Name accountType -Value $userDetailobj.accountType
        $object | Add-Member -MemberType NoteProperty -Name status -Value $userDetailobj.status
        [void] $users.add($object)
    }
    $pageObj = $userObj.page

}

#end region


#region Main Process
<#
    if Discovery Mode is set to default, only retreive local administrators will be run
#>

$adminAccounts = New-Object System.Collections.ArrayList
$adminuser = New-Object -TypeName PSObject

try {
    #region Find Account Admins
   
    if($DiscoveryMode -eq "Advanced"){
        $global:svcAccountUsers = get-svcAccountUsers
    }
        $adminUsers = $users.Clone()    
        foreach ($adminuser in $adminUsers) {
            $isFound = $false
            $adminuser = $adminuser.PSObject.Copy()
            if (($true -eq $sAMLEnabled) -and ($adminuser.admin -eq $true) -and ($adminuser.status -ne "INACTIVE") ) {
                Write-Log -ErrorLevel 3 -Message "Adding Admin Account - $($adminuser.email)"
                if($DiscoveryMode -eq "Advanced") {
                    $adminuser | Add-Member -MemberType NoteProperty -Name Account-Admin -Value $true
                    $adminuser | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                }
                $isFound = $true             
            } elseif ($false -eq $sAMLEnabled) {
                if($DiscoveryMode -eq "Advanced"){ 
                    $adminuser | Add-Member -MemberType NoteProperty -Name Account-Admin -Value $false
                    $adminuser | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                }
                $isFound = $true         
            } else {
                if($DiscoveryMode -eq "Advanced"){ 
                    $adminuser | Add-Member -MemberType NoteProperty -Name Account-Admin -Value $false
                    $adminuser | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                }
            }

             #region Advanced Discovery
            if($DiscoveryMode -eq "Advanced"){
                $isSvcAccount = isSvcAccount -userId $adminuser.id
                if ($true -eq $isSvcAccount) {
                        $adminuser | Add-Member -MemberType NoteProperty -Name Service-Account -Value $true
                        $isFound = $true   
                    } else {
                        $adminuser | Add-Member -MemberType NoteProperty -Name Service-Account -Value $false
                    }
                }

                if ($true -eq $isFound) {
                    $adminuser.PSObject.Properties.Remove("id")
                    $adminuser.PSObject.Properties.Remove("admin")
                    $adminuser.PSObject.Properties.Remove("accountType")
                    $adminuser.PSObject.Properties.Remove("status")
                    [void] $adminAccounts.Add($adminuser)   
                }      
            }
                   
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Account Discovery-Filtering failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
#endregion Main Process
return $adminAccounts


