<#
Slack User Role Definitions
is_admin = Indicates whether the user is an Admin of the current workspace
is_owner = Indicates whether the user is an Owner of the current workspace.
is_restricted = Indicates whether or not the user is a guest user.
is_ultra_restricted = Indicates whether the restricted user is a single-channel guest.
Is_app_user = Indicates whether the user is an authorized user of the calling app.
Is_bot = Indicates whether the user is actually a bot user. Bleep bloop. Note that Slackbot is special, so is_bot will be false for it.
#>

[string]$baseURL = "https://slack.com"
[string]$api = "$baseURL/api"
[string]$DiscoveryMode = $args[0] #Select "Default" or "Advanced"
[string]$OAuthToken = $args[1]
[string]$adminrole = $args[2]
[string]$svcacctrole = $args[3]


$accessToken = $OauthToken


#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Slack-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Slack Discovery"

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



#region Slack instance details
    #   Build headers and get user list
try {
   
    $headers = @{
    "Authorization" = "Bearer $accessToken"     
    "Accept" = "application/json, application/xml"
    }

# Get All Active Users
    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    # Specify Slack endpoint uri for Users
    $uri = "$api/users.list"

    # Specify HTTP method
    $method = "get"

    # Perform Auth Test
    $AuthTest = Invoke-RestMethod "$api/auth.test" -Method $method -Headers $headers

    # Send HTTP request
    $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Slack instance details

<#   ## Use for debug logging on returned user attributes

try {
        Write-Log -Errorlevel 0 -Message "Parsing List of Users"       
        Write-Log -ErrorLevel 0 -Message "Successfully found $($users.members.Count) Eligible Accounts"
        $admins = $users.members | where-object is_admin -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($admins.members.Count) Admin Accounts"   
        $owners = $users.members | where-object is_owner -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($owners.members.Count) Owner Accounts" 
        $appuser = $users.members | where-object is_app_user -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($appuser.members.Count) App User Accounts" 
        $guest = $users.members | where-object is_restricted -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($guest.members.Count) Guest Accounts" 
        $limitedguest = $users.members | where-object is_ultra_restricted -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($limitedguest.members.Count) Single Channel Guest Accounts"             
        $botuser = $users.members | where-object is_bot -like "True"
        Write-Log -ErrorLevel 3 -Message "Successfully found $($botuser.members.Count) Bot User Accounts" 
    }
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to parse User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception  
    }
    #>

#region get admin users

function get-adminusers{
    param(
        $user
    )
    try{
        Write-Log -ErrorLevel 0 -Message "Parsing List of Admin Users as defined by Admin Roles parameter: $($adminrole)"
          $isadmin = $false 
         
        foreach($role in $adminrole.split(",")){
            $filter = $role.split("=")[0]
            $switch = $role.split("=")[1]
        if($user.$filter -eq $switch)
        {
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

function get-svcacctusers{
    param(
        $user
    )
    try{
        Write-Log -ErrorLevel 0 -Message "Parsing List of Service Account Users as defined by Service Account Roles parameter: $($svcacctrole)"
        $issvcacct = $false 
            
        foreach($role in $svcacctrole.split(",")){
            $filter = $role.split("=")[0]
            $switch = $role.split("=")[1]
        if($user.$filter -eq $switch)
        {
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
if($DiscoveryMode -eq "Default")
{

$foundAccounts = @()
foreach ($user in $users.members)
{
    if($user.team_id -eq $AuthTest.team_id){$WorkspaceName = $AuthTest.team; $WorkspaceURL = $AuthTest.url}
     
    if($user)
        { 
            $object = New-Object -TypeName PSObject
             $object | Add-Member -MemberType NoteProperty -Name Workspace-Name -Value $WorkspaceName
             $object | Add-Member -MemberType NoteProperty -Name Workspace-URL -Value $WorkspaceURL
             $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.name
             $object | Add-Member -MemberType NoteProperty -Name Global-UserId -Value $user.id
             $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $user.is_admin
             $object | Add-Member -MemberType NoteProperty -Name Workspace-Owner -Value $user.is_owner
             $object | Add-Member -MemberType NoteProperty -Name Bot-User -Value $user.is_bot
             $object | Add-Member -MemberType NoteProperty -Name App-User-Account -Value $user.is_app_user
             $object | Add-Member -MemberType NoteProperty -Name Guest-Account -Value $user.is_restricted
             $object | Add-Member -MemberType NoteProperty -Name Restricted-Guest-Account -Value $user.is_ultra_restricted
             
              $foundAccounts += $object
        }
    }
}

if($DiscoveryMode -eq "Advanced")
{     

$foundAccounts = @()
foreach($user in $users.members)
{
        $isadmin = get-adminusers -user $user
        $issvcacct = get-svcacctusers -user $user
    if($user.team_id -eq $AuthTest.team_id){$WorkspaceName = $AuthTest.team; $WorkspaceURL = $AuthTest.url}

        $object = New-Object -TypeName PSObject
         $object | Add-Member -MemberType NoteProperty -Name Workspace-Name -Value $WorkspaceName
         $object | Add-Member -MemberType NoteProperty -Name Workspace-URL -Value $WorkspaceURL
         $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.name
         $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
         $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $issvcacct
         $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true

          $foundAccounts += $object
    
}
}
    #endregion Main Process
    
    # Use for Debugging Discovery
        # Add-Content -Path "c:\temp\results.txt" -Value $foundAccounts
    return $foundAccounts