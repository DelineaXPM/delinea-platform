$args = @("https://adb-7457224008350131.11.azuredatabricks.net","ec19d800-3d24-4727-bbdc-670e23d17710", "dose30200131096defda810006f5e0a45ff6" ,"admins","TargetGroup3,TargetGroup2","thycoticproservices.onmicrosoft.com")

#region define variables
#Define Argument Variables
[string]$databricks_url = $args[0]
[string]$clientid = $args[1]
[string]$clientsecret = $args[2]
[string]$adminGHroups= $args[3]
[string]$svcAcctGroups = $args[4]
[string]$localDomains = $args[5]

#Create Cretria arrays
$adminGroupArray = $adminGHroups.split(",")
$svcAcctGroupsArray = $svcAcctGroups.split(",")
$localDomainsArray = $localDomains.Split(",")

#Define Script Constants
[string]$scope = "all-apis"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\DataBricks-Connector.log"
[string]$LogFile = "c:\temp\DataBricksDiscovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Databricks User Discovery"
#endregion

#region Error handling and Logging
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel,$logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
    }
}

if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old logdata has been purged."
}



#endregion
 #region Get Token
 
 
 try {
    Write-Log -Errorlevel 0 -Message "Attempting to get the authentication Token from client info provided" 
    $response = Invoke-RestMethod -Uri "$databricks_url/oidc/v1/token" -Method POST -headers @{"Authorization"= "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($clientId):$($clientsecret)")))"; "Content-Type" = "application/x-www-form-urlencoded"}  -Body "grant_type=client_credentials&scope=$scope&client_id=$clientId&client_secret=$client_secret" -ErrorAction Stop
    $headers = @{
        "Authorization" = "Bearer $($response.access_token)"
        "Content-Type" = "application/json"
    }
} catch {    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to get the Auth Token" 
    Write-Log -ErrorLevel 2 -Message $Err.Exception 
    throw $Err.Exception
}
#endregion

#region User filtering functions
function isadmin{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [system.object]$user    
            
    )

    try
        {
            $isadmin = $false
            foreach($group in $user.groups)
            {
                foreach ($adminGroup in $adminGroupArray)
                {
                 

                    if($group.display -eq $adminGroup)
                    {
                        $isadmin = $true
                        break
                    } 
                
                    
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
            
 Return $isadmin  
}
function isSvcAcct{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [system.object]$user    
)

    try
        {
            $isSvcAcct = $false
            foreach($group in $user.groups)
            {
                foreach ($svcAcctGroup in $svcAcctGroupsArray)
                {
                 

                    if($group.display -eq $svcAcctGroup)
                    {
                        $isSvcAcct = $true
                        break
                    } 
                
                    
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
function isLocal{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [system.object]$user    
)

    try
        {
            $isLocal = $false
            foreach($localDomain in $localDomainsArray)
            {
                if($user.username.Contains($localDomain) -eq $true)
                {
                    $isLocal = $true
                    break
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
            
 Return $isLocal  
}

#endregion
function Get-DataBricksAdmins{
    param (
        [Parameter(Mandatory)]
        [hashtable]$headers,
        [Parameter(Mandatory)]
        [string]$dburl,
        [Parameter(Mandatory)]
        [Array]$UserListToVetAgainst
    )
    Write-Log -Errorlevel 0 -Message "Looking through the admin group now to get the user info" 
    $group_user_ids = @()
    try {
        $admingroup = Invoke-WebRequest -Uri "$dburl/api/2.0/preview/scim/v2/Groups?group_name eq admins" -Headers $headers -Method GET  | ConvertFrom-Json 
        }catch {    
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Failed to get group information on the admins group" 
            Write-Log -ErrorLevel 2 -Message $Err.Exception 
            throw $Err.Exception
        }
    Write-Log -ErrorLevel 0 -Message "Getting Group admin user IDs to compare. Have to pull all group data and then parse through"
    foreach($val in $admingroup.Resources){
        if($val.DisplayName -eq "admins"){
            try {
                $list = Invoke-WebRequest -Uri "$dburl/api/2.0/preview/scim/v2/Groups/$($val.id)" -Headers $headers -Method GET  | ConvertFrom-Json 
                }catch {    
                    $Err = $_
                    Write-Log -ErrorLevel 0 -Message "Failed to get membership group info for the admins group" 
                    Write-Log -ErrorLevel 2 -Message $Err.Exception 
                    throw $Err.Exception
                }
            $group_user_ids += $_object_
            foreach($mem in $list.Members){
                $_object_ = New-Object PSObject -Property @{
                    Id = $mem.Value
                }
                $group_user_ids += $_object_
            }
        }
    }
    foreach ($item in $UserListToVetAgainst) {
        if ($item.id -in [System.Array]$group_user_ids.id) {
            Write-Log -ErrorLevel 0 -Message "We Have a match $($item.id); Found an Admin"
            $object = New-Object PSObject -Property @{
                Username = $item.Username
                IsAdmin = $True
                IsServiceAccount = $False
            }
            $global:results += $object 
        }
    }
    return $global:results
}
#region Main Process
#Begin Main Process
$foundAccounts = @()
$users=  Invoke-WebRequest -Uri  "$databricks_url/api/2.0/preview/scim/v2/Users" -Headers $headers -Method GET | ConvertFrom-Json
foreach ($user in $users.Resources)
{   
    $isAdmin = isadmin -user $user
    $isLocal = isLocal $user
    $isServiceAccount = isSvcAcct -user $user
    if($isAdmin -eq $true -or $isServiceAccount -eq $true )
    {   
    
        $username = $user.userName
     
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name username -Value $username
        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
        
        $foundAccounts += $object
        
        

    }

}
#endregion

return  $foundAccounts
