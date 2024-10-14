[string]$baseURL = "https://slack.com"
[string]$api = "$baseURL/api"
[string]$DiscoveryMode = $args[0] #Select "Default" or "Advanced"
[string]$AccessToken = $args[1]
[string]$adminrole = $args[2]
[string]$svcacctrole = $args[3]
[bool]$OnlyAdminAccount = $true #if set $true then only admin users will display. if set $false then all users will display

if ($DiscoveryMode -notin "Default", "Advanced") { Throw "Invalid Discovery Mode" }

#Script Constants
[string]$logApplicationHeader = "Slack-Discovery"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\$LogApplicationHeader.log"
[int32]$LogLevel = 3
$rateLimit = 20 #as per official slack documentation 20 requests can be processed per min.
$count = 0
$usersPerPage = 5  #set value of numner of user per page as per needed. (noramlly 100-200 per users and max value is 1000 as per documentation)


#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0, 1, 2, 3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory, ValueFromPipeline)]
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel, $logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}
#endregion Error Handling Functions

#region Slack instance details
#build headers and get user list
try {
   
    $headers = @{
        "Authorization" = "Bearer $accessToken"     
        "Accept"        = "application/json, application/xml"
    }

    # Get All Active Users
    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    # Specify Slack endpoint uri for Users
    $uri = "$api/admin.users.list?limit=$usersPerPage"

    # Specify HTTP method
    $method = "get"

    # Perform Auth Test
    $AuthTest = Invoke-RestMethod "$api/auth.test" -Method $method -Headers $headers

    # Send HTTP request
    $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri -UseBasicParsing


    if (!([string]::IsNullOrEmpty($users.error))) {
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List due to error in response please check token and its validity"
        throw "Failed to retrieve User List due to error in response"
    }

    $fin_req = $users
    while (!([string]::IsNullOrEmpty($fin_req.response_metadata.next_cursor))) {
        if ($count -ge $rateLimit) {
            $count = 0
            start-sleep -Seconds 30
        }
        $count++
        $next_cursor = $fin_req.response_metadata.next_cursor
        $uri = "$api/admin.users.list?limit=$usersPerPage&cursor=$next_cursor"
        $fin_req = $(Invoke-RestMethod -Headers $headers -Method Get -Uri $uri -UseBasicParsing)
        $users.users += $fin_req.users  
    } 
    $users.users.count
    
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Slack instance details

#region get admin users
function get-adminusers {
    param(
        $user
    )
    try {
        Write-Log -ErrorLevel 0 -Message "Parsing List of Admin Users as defined by Admin Roles parameter: $($adminrole)"
        $isadmin = $false 
         
        foreach ($role in $adminrole.split(",")) {
            $filter = $role.split("=")[0]
            $switch = $role.split("=")[1]
            if (($user.$filter) -eq $switch) {
                $isadmin = $true
                break 
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to parse Admin Role List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }
    return $isadmin
}

function get-svcacctusers {
    param(
        $user
    )
    try {
        Write-Log -ErrorLevel 0 -Message "Parsing List of Service Account Users as defined by Service Account Roles parameter: $($svcacctrole)"
        $issvcacct = $false 
            
        foreach ($role in $svcacctrole.split(",")) {
            $filter = $role.split("=")[0]
            $switch = $role.split("=")[1]

            if (($user.$filter) -eq $switch) {
                $issvcacct = $true
                break 
            }
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to parse Service Account Role List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }
    return $issvcacct
}
#endregion Get Admin Users  

#region Main Process
if ($DiscoveryMode -eq "Default") {

    $foundAccounts = @()
    foreach ($user in $users.users) {
        #if ($user.team_id -eq $AuthTest.team_id) { $WorkspaceName = $AuthTest.team; $WorkspaceURL = $AuthTest.url }
        
        if ($OnlyAdminAccount -eq $true) {
            if (($user.is_admin) -eq $true) { 
                $object = New-Object -TypeName PSObject
                # $object | Add-Member -MemberType NoteProperty -Name Workspace-Name -Value $WorkspaceName
                # $object | Add-Member -MemberType NoteProperty -Name Workspace-URL -Value $WorkspaceURL
                $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.username
                $object | Add-Member -MemberType NoteProperty -Name Global-UserId -Value $user.id
                $object | Add-Member -MemberType NoteProperty -Name Email -Value $user.email
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $user.is_admin
                $object | Add-Member -MemberType NoteProperty -Name Workspace-Owner -Value $user.is_owner
                $object | Add-Member -MemberType NoteProperty -Name Primary-Workspace-Owner -Value $user.is_primary_owner
                $object | Add-Member -MemberType NoteProperty -Name Bot-User -Value $user.is_bot
                $object | Add-Member -MemberType NoteProperty -Name Guest-Account -Value $user.is_restricted
                $object | Add-Member -MemberType NoteProperty -Name Restricted-Guest-Account -Value $user.is_ultra_restricted
                
                $foundAccounts += $object
            }
        }
        if ($OnlyAdminAccount -eq $false) {
            if ($user) { 
                $object = New-Object -TypeName PSObject
                # $object | Add-Member -MemberType NoteProperty -Name Workspace-Name -Value $WorkspaceName
                # $object | Add-Member -MemberType NoteProperty -Name Workspace-URL -Value $WorkspaceURL
                $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.username
                $object | Add-Member -MemberType NoteProperty -Name Global-UserId -Value $user.id
                $object | Add-Member -MemberType NoteProperty -Name Email -Value $user.email
                $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $user.is_admin
                $object | Add-Member -MemberType NoteProperty -Name Workspace-Owner -Value $user.is_owner
                $object | Add-Member -MemberType NoteProperty -Name Primary-Workspace-Owner -Value $user.is_primary_owner
                $object | Add-Member -MemberType NoteProperty -Name Bot-User -Value $user.is_bot
                $object | Add-Member -MemberType NoteProperty -Name Guest-Account -Value $user.is_restricted
                $object | Add-Member -MemberType NoteProperty -Name Restricted-Guest-Account -Value $user.is_ultra_restricted
                
                $foundAccounts += $object
            }
        }
    }
}

if ($DiscoveryMode -eq "Advanced") {     

    $foundAccounts = @()
    foreach ($user in $users.users) {
        $isadmin = get-adminusers -user $user
        $issvcacct = get-svcacctusers -user $user
        #if ($user.team_id -eq $AuthTest.team_id) { $WorkspaceName = $AuthTest.team; $WorkspaceURL = $AuthTest.url }

        $object = New-Object -TypeName PSObject
        # $object | Add-Member -MemberType NoteProperty -Name Workspace-Name -Value $WorkspaceName
        # $object | Add-Member -MemberType NoteProperty -Name Workspace-URL -Value $WorkspaceURL
        $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.username
        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $issvcacct
        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true

        $foundAccounts += $object    
    }
}
#endregion Main Process

return $foundAccounts
