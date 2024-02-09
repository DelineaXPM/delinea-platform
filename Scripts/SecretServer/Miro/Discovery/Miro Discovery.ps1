#region define variables
#Define Argument Variables
try {

    [string]$DiscoveryMode = $args[0]
    [string]$baseURL = $args[1] + "/v2"
    [string]$orgId = $args[2]
    [string]$accesstoken = $args[3]   
}
catch {
    $Err = $_   
    throw "$Err.Exception args: $args" 

}




#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Miro-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Miro Discovery"
[System.Collections.ArrayList]$allAccounts = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:serviceTeamUserList = New-Object System.Collections.ArrayList
[string] $tokenHeader = "Bearer"
[string]$pageSize = 2 #Max Size is 100
[string]$localUserRole = "organization_internal_user"
[string]$adminUserRole = "organization_internal_admin"
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

    }
}
#endregion Error Handling Functions


#region Get All Users
 #Create Headers

 function RetrieveUsers {
    param(
        [Parameter(Mandatory)]
        [string]$role,
        [string] $cursor
    )
    try {
   
        $headers = @{
        "Authorization" = "$tokenHeader $accessToken"    
        }
     
        # Get full URL from baseUris
        $uri = $baseURL
        

        # Get All Active Users
        
        
        # Specify endpoint uri for Users
        if ("" -eq ($cursor)) {
            $uri = "$uri/orgs/$orgId/members?limit=$pageSize&role=$role"
        } else {
            $uri = "$uri/orgs/$orgId/members?cursor=$cursor&limit=$pageSize&role=$role"
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

function Get-Users {
    param(
        [Parameter(Mandatory)]
        [string]$role    )
    try {

        [System.Collections.ArrayList]$foundAccounts = New-Object System.Collections.ArrayList

        $tenantUrl = $baseURL

        #region Build User List
        Write-Log -Errorlevel 0 -Message "Obtaining List of $role Users"

        #Traverse though the list of Users in the system and determine if they are Privileged Accounts
        $more = $true
        $offset = $null
        while ($false -ne $more) {
            $localUserObj = RetrieveUsers -cursor $offset -role $role

            $localUsersList = $localUserObj.data
            foreach ($lUser in $localUsersList) {
                    # All accounts get added to ArrayList because they are all local accounts
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $tenantUrl
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $lUser.email
                    if ($DiscoveryMode -eq "Advanced") {
                        if ($role -eq $localUserRole) {
                            $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                            $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
                        } elseif ($role -eq $adminUserRole) {
                            $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                            $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $true
                        } else {
                            $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $false
                            $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $false
                        }
                    }
                    [void] $foundAccounts.add($object)
            }
            $offset = $localUserObj.cursor
            if ($null -eq $offset) {
                $more = $false
            }
        }
    } catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to Analyze the Users"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
    return $foundAccounts
}

#region Obtain List of Local Users
$adminAccounts = @(Get-Users -role $adminUserRole)
$localAccounts = @(Get-Users -role $localUserRole)


foreach($value in $localAccounts){$allAccounts.Add($value) | Out-Null}
foreach($value in $adminAccounts){$allAccounts.Add($value) | Out-Null}
#endregion Main Process
return $allAccounts


