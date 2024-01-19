#Args used for development (Remove before pushing to production):
$args = @("Advanced","https://prod-useast-b.online.tableau.com", "delineapsdev", "7f62078d-7bed-49a3-9ff4-8e38b188ad52", "toAdh4hs71taM1CttuN2NCA7WcHiVKfi3vslgshfkPA=", "SiteAdministratorCreator,SiteAdministratorExplorer", "ServiceAccts","JLutherPAT","XLirSzRLQlCBDMOMsPJPTQ==:CJz67F3WKe5oOStIjHaRnSbQIJaeDRZf")

#region define variables
    #Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$ContentURL = $args[2]
[string]$tokenUrl = "$baseURL/api/3.21/auth/signin"
[string]$api = "$baseURL/api/3.21"
[string]$clientId = $args[3]
[string]$clientSecret = $args[4]
[string]$adminRole= $args[5]
[string]$svcAcctGroupNames = $args[6]

#For development testing only, replace with requisite JWT information or remove before pushing to production:
[string]$PATokenName = $args[7]
[string]$PATokenSecret = $args[8]

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Tableau-Discovery.log"
[string]$LogFile = "c:\temp\Tableau-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Tableau Discovery"
[string]$scope = "tableau:groups:read,tableau:users:read"
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


# For development, a Personal Access Token is used in lieu of a JWT Access Token.
 # For reference: https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_ref_authentication.htm
#region Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token"  
    # Prepare body for the token request
        $body = @"
<tsRequest>
    <credentials personalAccessTokenName=`"$PATokenName`" personalAccessTokenSecret=`"$PATokenSecret`">
        <site contentUrl=`"$contentURL`"/>
    </credentials>
</tsRequest>
"@


    # Make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body

    # Extract the access token and site-id from the response
    $accessToken = $response.tsresponse.credentials.token
    $siteID = $response.tsResponse.credentials.site.id
    
    Write-Log -Errorlevel 0 -Message "Access Token Successfuly Obtained "

}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Tableau Access Token failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Get Access Token 

#region Discovery Filtering Functions
function isSvcAcct{
param(
$svcAccts,
$userName
)
try 
{
       
    foreach ($group in $svcAccts)
        {  $isSvcAcct = $false
            if($svcAccts.name -eq $username)
            {
                $isSvcAcct = $true
            
                break
            } 
        }
    }
catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }

return $isSvcAcct
}

#endregion

#region Get All Users
 #Create Headers
 try {
   
    $headers = @{
    "X-Tableau-Auth" = "$accessToken"     
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    
    # Get All Active Users
    
    
    # Specify endpoint uri for Users
    $uri = "$api/sites/$siteID/users"

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
    $userlist = $users.tsResponse.users.user
    Write-Log -ErrorLevel 0 -Message "Successfully found $($userlist.Count) Total User Accounts"  
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion


#region get admin users
    # Fetching users associated with this role(s)
function get-adminusers{
    param(
        $user
    )
    try{
          $isadmin = $false 
         
        foreach($role in $adminrole.split(",")){
        if($user.siterole -eq $role)
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

#endregion Get Admin Users  

#region get Service Accounts

    # Fetching Accounts associated with this Group name(s)
function get-SvcAccounts{
    try {   
        ##Create Roles Array
        If ($svcAcctGroupNames)
        { #Create array for multiple groupIds and users
            $svcActGroupIdArray = @()
            $svcAccountIds = @()
            ### Create Array of SvcAccount group names from arguments
            $svcActGroupNameArray = $svcAcctGroupNames.split(",") 
            #Pull a list of all groups and select the matches and store the IDs into an array
            $AllGroups = Invoke-RestMethod -Uri "$api/sites/$siteID/groups" -Headers $headers 
            foreach($group in $svcActGroupNameArray){
            $svcAcctGroups = $AllGroups.tsresponse.groups.group | Where-Object name -EQ $group
            $svcActGroupIdArray += $svcAcctGroups
            }
        # Perform a search for each group ID and add matching users to an array
            foreach ($group in $svcActGroupIdArray) {
                $groupid = $group.id
                $svcAcctslist = Invoke-RestMethod -Uri "$api/sites/$siteID/groups/$groupid/users" -Headers $headers
                $svcAccountIds += $svcAcctslist.tsresponse.users.user 
                    }
                Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountIds.Count) Service Accounts"  
        }
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accounts List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }
return $svcAccountIds
}

#endregion Get Admin Users  

#region Main Process

#Region Get Advanced User Data
<#
    if Discovery Mode is set to default, parsing svcAccount groups is skipped and role name is listed explicitly
#>

if($DiscoveryMode = "Advanced"){

    $svcAccountIds = get-SvcAccounts  
   
}
#endregion

#define Output Array
$foundAccounts = @()

Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users"  
    if($DiscoveryMode -eq "Default")
    {
        foreach ($user in $userlist)
                {   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.name
                    $object | Add-Member -MemberType NoteProperty -Name siteRole -Value $user.SiteRole 
                    
                    $foundAccounts += $object
                    
                }
        }
    else{
        foreach ($user in $userlist)
        {      
            ### check if is admin
            if($adminRole) 
            {
                $isadmin = get-adminusers -user $user
            }
            else 
            {
                $isadmin = "N\A"
            }

            #Check Service Account
            if ($svcAcctGroupNames)
                {
                    $isServiceAccount = isSvcAcct -svcAccts $svcAccountIds -username $user.name
                }   
                else   
                {
                    $isServiceAccount = $false
                }                  

                if($isAdmin -eq $true -or $isServiceAccount -eq $true )
                {   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.name
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                    
                    $foundAccounts += $object
                    
                    

                }
            }
            Write-Log -ErrorLevel 0 -Message "List of Admin Users defined by Admin Roles parameter: $($adminrole)"
            Write-Log -Errorlevel 0 -Message "List of Service Accounts defined by Service Account Group Names parameter: $($svcAcctGroupNames)" 
        }
       
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Account Discovery-Filtering failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception 
}
#endregion Main Process
Write-Log -ErrorLevel 0 -Message "Successfully Found $($foundAccounts.Count) Matching Accounts"  
return $foundAccounts