# Pre-requisite:
#   Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
# Windows 7:
#   start-process powershell -verb RunAs Administrator
#   add-windowscapability -name Rsat.activedirectory.ds-lds.tools -online

$pw = ""
$un = ""
## This block will be used when passing args in from Secret Server

    $DiscoveryMode       = $args[0]
    $baseURL             = $args[1]
    $apiAccessToken      = $args[2]
    $presetAdminGroups   = $args[3]
    $presetServiceGroups = $args[4]

#region define variables
#Define descriptive variables for use in script & set values.

#Script Constants
[string]$LogFile              = $env:temp+"\Thycotic Software Ltd\Distributed Engine\log\LoginVSI-Connector.log"

[int32]$LogLevel              = 3
[string]$scope                = "useraccount"
[string]$timeformat           = "yyyy-MM-ddTHH:mm:ss.fffzzz"
$globalResults                = @{}
$foundAccounts                = @()
$requestHeaders               = @{
    'Content-Type' = 'application/json'
    'Authorization' = "Bearer $apiAccessToken"
    }

$requestBody = ConvertTo-Json -InputObject $requestObject

function CreatePsCredObj {
    param (
    [CmdletBinding()]
    [Parameter(Mandatory)]
    [string]$Password,
    [Parameter(Mandatory)]
    [string]$username
    )
    return New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString -String $Password -AsPlainText -Force))
}

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
    }
}

function IsPrivilege {
    Param ($PrivGroups,  $UsersGroups )
    $isPrivUser = $False

    Try {
        #Process Users
        Write-Log -Errorlevel 0 -Message "Matching Discovered Users to Admin/Service Group (Privilege) Membership"  
    
        # get list of all users ...
        if ($PrivGroups.split(',').count -gt 1) {
            foreach ($PrivGroupID in $PrivGroups.split(',')) {
                if ($usersgroups.contains($PrivGroupID.trim('"',"'"))) {
                    $isPrivUser = $true
                    break
                }
            }
        }
        elseif ($PrivGroups.split(',').count -eq 1) {
                if ($usersgroups.contains($privgroups.trim('"',"'"))) {
                    $isPrivUser = $true
                }
            }
    }

    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED:  Matching Discovered Users to Admin/Service Group Membership"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $isPrivUser
}

function Change-Password {
    Param ($userID, $userName, $userDomain, $newPassword)

    if ($newPassword.length -lt 128) {
        $requestObject = @{
            "password"= $newPassword
            "domain"= $userDomain
            "username"= $userName
        }

        $requestBody = ConvertTo-Json -InputObject $requestObject

        try {
            $userRPCResponse = Invoke-RestMethod -Method put -Uri "$($baseUrl)/v6/accounts/$userID"  -skipcertificatecheck -headers $requestHeaders -body $requestRPCBody
        }
        catch {
            [int]$statusCode = $_.Exception.$userRPCResponse.StatusCode;
            
            switch ($statusCode) {
                404 { Write-Host -Object 'API Connection Error Code - Not Found' }
                409 { Write-Host -Object 'API Connection Error Code - Conflict' }
                400 { Write-Host -Object 'API Connection Error Code - Bad Request' }
                401 { Write-Host -Object 'API Connection Error Code - Unauthorized' }
                default { throw }
            }
        }
    }
}

function Get-LDAPConfigGroups {
    $uri = "https://10.163.0.41/publicApi/v7-preview/ldap-configuration/identity-server"

    $foundAccounts = @()

    $requestObject = @{
        "orderBy"   = "name"
        "direction" = "asc"
        "count"     = "100"
    }
    
    $requestBody = ConvertTo-Json -InputObject $requestObject
    
    $admin = "None"
    $readOnly = "None"

    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Configured Domain Groups & Group Members"  

    try {
        
        $accountGroupsResponse = Invoke-RestMethod -Method get -Uri $uri  -skipcertificatecheck -headers $requestHeaders
        
        return $accountGroupsResponse.adminGroupName, $accountGroupsResponse.readOnlyGroupName
    }
    catch {
        [int]$statusCode = $_.Exception.Response.StatusCode;
        
        switch ($statusCode) {
            404 { Write-Log -Errorlevel 0 -Message 'API Connection Error Code - Not Found' }
            409 { Write-Log -Errorlevel 0 -Message 'API Connection Error Code - Conflict' }
            400 { Write-Log -Errorlevel 0 -Message 'API Connection Error Code - Bad Request' }
            401 { Write-Log -Errorlevel 0 -Message 'API Connection Error Code - Unauthorized' }
            default { throw }
        }
    return $statusCode
    }
}

function Get-ADGroupMembership {
    param ([string]$adGroup, [string]$category)
    $foundAccounts = @()

    ## Ok, 1st, make a call to the Get LDAP Config API to get the membership of the AD.  This will have 2 returns - 1 Admin & 1 ReadOnly.  Each may be comma separated.
    try {
        $groupMembershipResult = get-adgroupmember -credential $mycred -identity  $adGroup -recursive | select SamAccountName, objectclass

        foreach ($user in $groupMembershipResult) {
            $object = New-Object -TypeName PSObject

            $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.samaccountname
            write-host $user.SamAccountName
            try {
                $Domain = $( get-aduser -credential $mycred -identity $user.samaccountname | select userprincipalname).UserPrincipalName.Split("@")[1]
                $object | Add-Member -MemberType NoteProperty -Name Domain -Value $Domain
            }
            catch {
                $Domain = "N/A"
                $object | Add-Member -MemberType NoteProperty -Name Domain -Value $Domain
            }
            
            $object | Add-Member -MemberType NoteProperty -Name ADGroup -Value $AdGroup
            $object | Add-Member -MemberType NoteProperty -Name IsLocal -Value $False
            if ($category -eq 'Service') {
                $object | Add-Member -MemberType NoteProperty -Name IsService -Value $True
                $object | Add-Member -MemberType NoteProperty -Name IsAdmin -Value $False
            }
            elseif ($category -eq 'Admin') {
                $object | Add-Member -MemberType NoteProperty -Name IsService -Value $False
                $object | Add-Member -MemberType NoteProperty -Name IsAdmin -Value $True
            }
            $foundAccounts += $object
        }

        return $foundAccounts
    }  

    catch {
        [int]$statusCode = $_.Exception.Response.StatusCode;
        
        switch ($statusCode) {
            404 { Write-Host -Object 'API Connection Error Code - Not Found' }
            409 { Write-Host -Object 'API Connection Error Code - Conflict' }
            400 { Write-Host -Object 'API Connection Error Code - Bad Request' }
            401 { Write-Host -Object 'API Connection Error Code - Unauthorized' }
            default { throw }
        }

        Write-Log -ErrorLevel 0 -Message "FAILED:  Discovering All Users."
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception     
    }

}
function Get-AllUsers {
    $listUsersApi = "$($baseUrl)/v6/accounts"
    $uri = $base+$listUsersApi
    $foundAccounts = @()

    $requestObject = @{
        "orderBy"   = "domain"
        "direction" = "asc"
        "count"     = "100"
    }
    
    $requestBody = ConvertTo-Json -InputObject $requestObject
    
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering All Users"  

    try {
        $userListResponse = Invoke-RestMethod -Method get -Uri "$($baseUrl)/v6/accounts"  -skipcertificatecheck -headers $requestHeaders -body $requestBody
    }

    catch {
        [int]$statusCode = $_.Exception.Response.StatusCode;
        
        switch ($statusCode) {
            404 { Write-Host -Object 'API Connection Error Code - Not Found' }
            409 { Write-Host -Object 'API Connection Error Code - Conflict' }
            400 { Write-Host -Object 'API Connection Error Code - Bad Request' }
            401 { Write-Host -Object 'API Connection Error Code - Unauthorized' }
            default { throw }
        }

        Write-Log -ErrorLevel 0 -Message "FAILED:  Discovering All Users."
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
        
    }

    foreach ($user in $userListResponse.items) {
        $object = New-Object -TypeName PSObject

        $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.username
        $object | Add-Member -MemberType NoteProperty -Name UserID -Value $user.id
        $object | Add-Member -MemberType NoteProperty -Name UserEnabled -Value $user.enabled
        $object | Add-Member -MemberType NoteProperty -Name Domain -Value $user.domain
        $object | Add-Member -MemberType NoteProperty -Name User-Email -Value $user.email
        $object | Add-Member -MemberType NoteProperty -Name IsService -value $True
        $object | Add-Member -MemberType NoteProperty -Name IsAdmin -value $false
        $object | Add-Member -MemberType NoteProperty -Name IsLocal -value $False

        $foundAccounts += $object
    }
return $foundAccounts
}
     
####################################
### Main Body Commands
###

$myCred = CreatePsCredObj -password $pw -username $un
#$userList = Get-AllUsers 

$adminGroup, $readOnlyGroup = get-ldapconfiggroups
$userList += Get-ADGroupMembership $adminGroup "Admin" 
$userList += Get-ADGroupMembership $readOnlyGroup "Service"

#returning to Secret Server
return $userList