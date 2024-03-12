# Script usage
# use powershell script for Discovering of EntraID/Azure/Office 365 Local Accounts.
# parameters to provide in each case are:
# Discovery $[1]$TenantID $[1]$applicationid $[1]$ClientSecret $[1]$admin-roles $[1]$Service-Account-Groups "<Detailed or Basic> <true or false>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

[string]$tenantid = $args[0] 
[string]$applicationid = $args[1] 
[string]$clientsecret = $args[2] 
[string]$adminCriteria = $args[3] 
[string]$svcAccountGeoups =  $args[4] 
[string]$dicoveryLevel = $args[5] #Detailed/Basic
[string]$includeExternal = $args[6] #If set to true external user/domains (Guests) will be included 
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\EntraID-Connector.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "EntraID Discovery"


#region Error Handling Fumctions
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

#  Log Cleanup  
if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old log data has been purged."
}

# Modules
try {
    Write-Log -Errorlevel 0 -Message "Loading Microsoft Graph PowerShell modules"
    # Modules needed for Microsoft Graph Powershell
    Import-Module Microsoft.Graph.Users.Actions -ErrorAction Stop
} catch {    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to load Microsoft Graph PowerShell modules"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

# Check if variables are actually set
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$tenantid -or !$applicationid -or !$clientsecret ) {
    
    Write-Log -Errorlevel 0 -Message "One or more variables are not set"
    throw "One or more variables are not set"
}

# If tenantid or any other variable contains $[1] the script will stop
if ($tenantid -like '$[1]*' -or $applicationid -like '$[1]*' -or $clientsecret -like '$[1]*' -or $thy_username -like '$*' -or $thy_password -like '$*') {
    Write-Log -Errorlevel 0 -Message "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
    throw "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
}


Write-Log -Errorlevel 0 -Message "All variables correctly set"


#endregion

#region admin user functions

function get-AdminUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Admin users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are assigned to EntraID Administrative Roles
     are passwd in as a comma seperated list of the Role namesthat Identify Administrators.
    
    .EXAMPLE
    An example: "Global Administrator, Application Administrator"
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        # Create Roles Array
      
        If ($adminCriteria)
        {
            # Create Array of Admin Roles
            
            #Clear Parametwr List
           $adminRoleArray = $adminCriteria.split(",")
           $adminUsers = @()
           
            foreach ($role in $adminRoleArray  ) {
  
                    $roleObject = Get-MgDirectoryRole |Where-Object {$_.DisplayName -match $role }     
                    $roleUsers = Get-MgDirectoryRoleMember -DirectoryRoleId $roleObject.Id

                  
                    foreach($roleUserId in $roleUsers)
                    {
                        $adminUsers += $roleUserId
                    }

                   
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($adminUsers.Count) Admin Accounts"    
                

        }   
    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve admin User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception  
    }
 return $adminUsers
} 
function isadmin{
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$userId    
        
    
    )

    try
        {
            
    
            foreach ($adminUser in $global:adminUsers)
            { 
                if($adminuser.id -eq $userId)
                {
                    $isadmin = $true
                    break
                } 
                else
                {
                    $isadmin = $false
                }
                
            }
        }
    catch   
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check if Admin Acct Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception <#Do this if a terminating exception happens#>
        }
            
 Return $isadmin  
}
#endregion Admin User Functions  

#region Service Account Functions
function get-svcAccountUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Service Account users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are members of 
    Service Account Groups  are Groups in a comma seperated list of Group Nmaes that Identify Service Account Users.
    
    .EXAMPLE
    An example: Service Team , PS Team
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        #Create Roles Array
      
        If ($svcAccountGeoups)
        {
            # Create Array of Serice Account Groups
            $svcGroupArray = $svcAccountGeoups.split(",")
            #Clear Parametwr List
          
           $svcUsers = @()
            
                   
                    foreach($Group in $svcGroupArray )
                    {
                        
                        $results =  Get-MgGroup -all |where-object {$_.DisplayName -match $Group}
                        $svcUserlist = Get-MgGroupMember -GroupId $results.id
                        foreach ($groupUser in $svcUserlist) {
                            $svcUsers +=  $groupUser.Id
                         
                        }
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcUsers.Count) Service Accounts"    
                

        }   
    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve ServiceAccount User List"
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
            
    
            foreach ($svcAcctUser in $global:svAcctUsers)
            { 
                if($svcAcctUser -eq $userId)
                {
                    $isSvcAcct = $true
                    break
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

# Create client credentials and stored in creds variable using the applicationid and clientsecret variables
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationid, (ConvertTo-SecureString -String $clientsecret -AsPlainText -Force)

# Connect to Microsoft Graph using the client credentials
try {

    Connect-MgGraph -ClientSecretCredential $creds -TenantId $tenantid -NoWelcome -ErrorAction Stop
    
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "EntraIs Authentication Failedt Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception          
}

Write-Log -Errorlevel 0 -Message "Connected to: $TenantId with applicationID: $applicationid" 

Write-Log -Errorlevel 0 -Message "Retrieving User List"
try {

    if ($dicoveryLevel -like "Detailed"){
    $global:adminUsers = @()
    $global:svAcctUsers = @()
    $global:adminUsers = get-AdminUsers
    $global:svAcctUsers = get-svcAccountUsers
    }
    
    $users = Get-MgUser -Filter 'accountEnabled eq true' -All -Property *
    $foundAccounts = @()
    
    foreach($user in $users)
    {
        $userId = $user.Id
        if ($dicoveryLevel -like "Detailed"){
    
            $isAdmin  = isadmin -userId $userId  
            $isSvcAccount = isSvcAccount -userId $userId
        
        }
        if ( $user.userPrincipalName.Contains("#EXT#") -eq $false)
      {
        $isLocal = $true
        $userName = $user.UserPrincipalName
      }
      else {
        $isLocal = $false
        $userName = $user.UserPrincipalName
      }
      if ($includeExternal -ne $true -and $isLocal -eq  $false){continue}
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name Domain -Value $user.UserPrincipalName.Split("@")[1]
        $object | Add-Member -MemberType NoteProperty -Name username -Value $userName
      
       if($dicoveryLevel -like "Detailed") 
      {
       

        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isSvcAccount
        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal

      }
      $foundAccounts += $object

    }
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Main Process Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception   }

return $foundAccounts
