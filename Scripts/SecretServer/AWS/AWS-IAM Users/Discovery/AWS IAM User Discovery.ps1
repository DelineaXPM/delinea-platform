# Script usage
# use powershell script for Discovering of AWS Local Accounts.
# parameters to provide in each case are:
# For IAM User-Advancd Discovery "IAMUser-Advanced" $[1]$AccessKey $[1]$SecretKey $[1]$Admin-Criteria $[1]$SVC-Account-Criteria 



# Uncomment the line below to enable TLS 1.2 if needed
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#region define variables
#Define Argument Variables

[string]$DiscoveryMode = $args[0]
$AccessKey = $args[1]
$SecretKey = $args[2]
[string]$adminCriteria= $args[3]
[string]$svcAcctGroups = $args[4]




#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\AWS-Connector.log"
#[string]$LogFile = "c:\temp\AWS-Discovery.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "AWS User Discovery"

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


###   ###   ###   ###   ###  Log Cleanup  ###   ###   ###   ###   ###
if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old logdata has been purged."
}

###   ###   ###   ###   ###    Modules    ###   ###   ###   ###   ###
try {
    Write-Log -Errorlevel 0 -Message "Loading AWS Tools PowerShell modules"
    # Modules needed for AWS Tools Powershell
    Import-Module AWS.Tools.Common -ErrorAction Stop
} catch {    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to load AWS.Tools.Common PowerShell modules"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Error Handling Functions

#Begin Main Process

try {
    Write-Log -ErrorLevel 0 -Message "Authenticatiing and Getting User List"
    
    # Authenticate
    Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey
   
    #Get user List
    $users = Get-IAMUserList
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to get List of Users"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#region admin user functions

function get-AdminUsers{
    <#
    .SYNOPSIS
    This Function returns a list of Admin users
    
    .DESCRIPTION
    This Function returns a list of Admin users that are assigned AWS Permision Policies
    dmin Policiws are passwd in as a comma seperated list of the Policy name and arn KeyValue pair that Identify Administrators.
    
    .EXAMPLE
    An example: Admin Access = arn:aws:iam::aws:policy/AdministratorAccess",Custom Access=arn:aws:iam::aws:policy/Custom Access"
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        ##Create Roles Array
      
        If ($adminCriteria)
        {
            ### Create Array of Admin Roles
            
            #Clear Parametwr List
           $adminRoleArray = $adminCriteria.split(",").Split("=")[1] 
           $adminUsers = @()
            foreach ($role in $adminRoleArray  ) {
                    $roleArn = $role.trim()
                    $policy = Get-IAMEntitiesForPolicy -PolicyArn $roleArn
                    $policyUsers  = $poilicyUsers.PolicyUsers
                    foreach($policyUser in $policyUsers)
                    {
                        $adminUsers += $policyUser.UserId
                    }
                    $policyGroups = $policy.PolicyGroups
                    foreach($policyGroup in $policyGroups )
                    {
                        $groupName = $policyGroup.GroupName
                        $group = Get-IAMGroup -GroupName $groupName
                        $groupUsers = $group.users
                        foreach ($groupUser in $groupUsers) {
                            $adminUsers +=  $groupUser.UserId
                         
                        }
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($adminUsers.Count) Admin Accounts"    
                

        }   
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
                if($adminuser -eq $userId)
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
            Write-Log -ErrorLevel 0 -Message "Check if Service Acct Failed"
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
    Service Account Groups Policiws are passwd in as a comma seperated list of Group Nmaes that Identify Service Account Users.
    
    .EXAMPLE
    An example: Infrastructure-Service Accounts
  
    #>
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Account Users"       
        ##Create Roles Array
      
        If ($svcAcctGroups)
        {
            ### Create Array of Serice Account Groups
            $svcGroupArray = $svcAcctGroups.split(",")
            #Clear Parametwr List
          
           $svcUsers = @()
            
                   
                    foreach($Group in $svcGroupArray )
                    {
                        
                        $results = Get-IAMGroup -GroupName $Group
                        $groupUsers = $results.users
                        foreach ($groupUser in $groupUsers) {
                            $svcUsers +=  $groupUser.UserId
                         
                        }
                    }
                    
                    
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcUsers.Count) Service Accounts"    
                

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
            
    
            foreach ($svcAcctUser in $global:svcAcctUsers)
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

If ($DiscoveryMode -eq "IAMUser-Advanced" )
{
   try {
    Write-Log -ErrorLevel 0 -Message "Begin Main User Processs"
    #Get Admin User List
    $global:adminUsers = get-AdminUsers
    $global:svcAcctUsers = get-svcAccountUsers
    
    $foundAccounts = @()
    foreach ($user in $users)
    {
        $userId = $user.UserId
        $isAdmin = isadmin -userId $userId
        $isServiceAccount = isSvcAccount -userId $userId
        if ($user.path -eq "/") 
            {
                $isLocal = $true
            } 
        else 
            {
                    $isLocal = $false
            }
        if(($isAdmin -eq $true -or $isServiceAccount -eq $true ) -and $isLocal -eq $true )
                {   
                
                    $userName = $user.UserName
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $userName
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                    
                    $foundAccounts += $object
                }
    }
   }
   catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Error in Main User Process"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception <#Do this if a terminating exception happens#>
   } 
 

}

  Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($foundAccounts.count)  Accounts"    
return $foundAccounts
