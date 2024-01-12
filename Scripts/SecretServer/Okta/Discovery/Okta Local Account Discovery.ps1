<#
    .SYNOPSIS
    Okta Local Account Discovery.
    
    .DESCRIPTION
    This script will Discover local accounts as determind by the parameters send from the Privileged Account Secret.

    Expected arguments: $TARGET $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD
    
    .NOTES
    There are there aparameters that control the accounts that are returned 
     - $Admin-roles
     - Service-Acct-attributes
     - 
    
#>
### 

# Expected Argd args=@("Discovery Mode Advanced/Default"Service Now Tenenant Base URL",SNOW Priovileged Username","SNOW Priovileged Password",""SNOW Client ID","SNOW Client Secret" ,"Private Key" ,"Admin Role ID","Local Group ID"  )


#region define variables
#Define Argument Variables

[string]$DiscoveryMode = $args[0]
[string]$baseURL = $args[1]
[string]$tokenUrl = "$baseURL/oauth_token.do"
[string]$api = "$baseURL/api/now"
[string]$username = $args[2]
[string]$password = $args[3]
[string]$clientId = $args[4]
[string]$clientSecret = $args[5]
[string]$adminRole= $args[6]
[string]$svcAcctGroupId = $args[7]
[string]$localGroupId = $args[8]

<#
The following is for debuging Parameters being sent by Secret Server

$value = "$baseURL $username $password $clientId $clientSecret $adminRole $svcAcctGroupId $localGroupId"
Add-Content -Path "c:\temp\snoq.txt" -Value $value
#>

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\ServiceNow-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "ServiceNow Discovery"
[string]$scope = "useraccount"
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


#region Get Access Token
#Get Access Token
try {
    Write-Log -Errorlevel 0 -Message "Obtaining Access Token"
    # Prepare body for the token request
    $body = @{
                grant_type    = "password"
                client_id     = $clientId
                client_secret = $clientSecret
                username      = $username
                password      = $password
                scope         = $scope
            }
    # Make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body

    # Extract the access token from the response
    $accessToken = $response.access_token
    
    Write-Log -Errorlevel 0 -Message "Access Tiken Successfuly Obtailed "

}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining ServiceNow Access Token failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

#endregion Get Access Token



#region Discovery Filtering Functions
<# The ys Admin and isSvcAcct Functions will not be used in Default mode#>
function isadmin{
    param(
    $adminUsers,
    $userId
    )

    try
        {
            
    
            foreach ($adminUser in $adminUsers.result)
            { 
                if($adminUser.user.value -eq $userId)
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
            
    $isadmin
}
function isSvcAcct{
param(
$svcAccts,
$userId
)
try 
{
        
    foreach ($group in $svcAccts.result)
        { 
            if($svcAccts.user.value -eq $userId)
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
        throw $Err.Exception 
    }

return $isSvcAcct
}
function isLocal{
    param(
    $localUsers,
    $userId
    )
    try
    {
       
        foreach ($localUser in $localUsers.result)
        {
            if($localUser.user.link.Contains($userid) -eq $true)
            {
                $isLocal = $true
                
                break
            } 
            else
            {
                $isLocal = $false
            }
               
        }
        
        
    
    }
    catch 
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check if Is Local Acct Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception     }        
`  return $isLocal
}
#endregion

#region Get All Users
 #Create Headers
 try {
   
    $headers = @{
    "Authorization" = "Bearer $accessToken"     
    "Accept" = "application/json, application/xml"
    "Content-Type" = "application/json, application/xml"
    }

    Write-Log -Errorlevel 0 -Message "Obtaining List of Users"    
    
    # Get All Active Users
    
    
    # Specify endpoint uri for Users
    $uri = "$api/table/sys_user?sysparm_query=active%3Dtrue"

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $users = Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
}

catch {
    $Err = $_    
    Write-Log -ErrorLevel 0 -Message "Failed to retrieve User List"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion


#region get admin users
# Fetching users associated with this role
function get-AdminUsers{
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        ##Create Roles Array
      
        If ($adminRole)
        {
            ### Create Array of Admin Roles
            
            #Clear Parametwr List
            $sysparm_querry = ""
            $adminRoleArray = $adminRole.split(",") 
            foreach ($role in $uri =$adminRoleArray     ) {
                        $roleId = $role.split("=")[1]
                    if(!$sysparm_querry)
                    {
                        $sysparm_querry = "role=$roleId"
                    }
                    else {
                        $sysparm_querry = "$sysparm_querry^ORrole=$roleId"

                    }
                    }
                $uri = "$api/table/sys_user_has_role?sysparm_query=$sysparm_querry" 
                $adminUsers = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($adminUsers.result.Count) Admin Accounts"    
                

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

#endregion Get Admin Users  

#region get Service Accounts

# Fetching Accounts associated with this/these Group/s
function get-SvcAccounts{
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Service Accounts"       
        ##Create Roles Array
        If ($svcAcctGroupId)
        {
            #### Clear System_params
            $sysparm_querry = ""    
            ### Create Array of Admin Roles
            $svcActGroupIdArray = $svcAcctGroupId.split(",") 
            <# Groups Are Returned By sys_id.  This section will create a list of Group sys_ids to Check #>
            foreach ($group in $svcActGroupIdArray ) {
                        $groupId = $group.split("=")[1]
                        if(!$sysparm_querry)
                        {
                            $sysparm_querry = "group=$groupId"
                        }
                        else {
                            $sysparm_querry = "$sysparm_querry^ORgroup=$groupId"
                        }
                    }
                $uri = "$api/table/sys_user_grmember?sysparm_query=$sysparm_querry" 
                $svcAccountIds = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
                Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($svcAccountIds.result.Count) SErvice Accounts"  
        }
        
       
    }
    catch {
        $Err = $_    
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Service Accountsr List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception  
    }
return $svcAccountIds
}

#endregion Get Admin Users  

#region Get Local Users
function get-LocalUsers{
    try{ 

    
        #Check if GroupID Provided
       If ($localGroupId)
       {
            
            # Specify endpoint uri
            $uri = "https://authteam02904.service-now.com/api/now/table/sys_user_grmember?sysparm_query=group=$localGroupId"
    
            # Specify HTTP method
            $method = "get"
    
            # Specify HTTP method
            $method = "get"
            # Send HTTP request
            $LocalUsers= Invoke-RestMethod -Headers $headers -Method $method -Uri $uri 
            Write-Log -ErrorLevel 0 -Message "Sueccessfully found $($LocalUsers.result.Count) SErvice Accounts"  
       }        
    }
    
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Failed to retrieve Local User List"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception   
    }
return $LocalUsers    
}

#endregion Get Local Users

#region Main Process

#Region Get Advanced User Data
<#
    if Discovery Mode is set to default, only the get-LocalAccounts will be run
#>

if($DiscoveryMode = "Advanced"){

  $adminUsers =  get-AdminUsers  
  $svcAccountIds = get-SvcAccounts  

}
$LocalUsers = get-LocalUsers
#endregion

#define Output Array
$foundAccounts = @()

Try {
    #Process Users
    Write-Log -Errorlevel 0 -Message "Discovering Users"  
    if($DiscoveryMode -eq "Default")
    {
        foreach ($user in $users.result)
        {
            $userId = $user.sys_id
            
            ###check is Local
            
            if ($localGroupId)
                {
                    
                    $isLocal = isLocal -localUsers $LocalUsers -userId $userId
                }
            else 
                {
                    <#ServiceNow note Check if Federated Id has a Value.  Typical value is something 
                    Like YCqviKocof/+7pmCk6IXdayQzerT2v5t1NozqEV2l+I= . If Federated there would be a Value afte rth = sign #>
                  
                    if (!$user.federated_id.Split("=")[1] )
                        {
                            $isLocal = $true
                        }
                    else 
                        {
                            $isLocal = $false
                        }
    
                }
                              
                if( $isLocal -eq $true )
                {   
                
                    $Username = $user.user_name

                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenanturl -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                    
                    $foundAccounts += $object
                    
                }
            }
        }
    else{
        foreach ($user in $users.result)
        {
            $userId = $user.sys_id
             if ($userId -eq "5815efce1bc2f150b64da824604bcb8b")
            {
                Write-Host $username
            }
            
            ### check if is admin
            if($adminRole) 
            {
                $isadmin = isadmin -adminUsers $adminUsers -userId $userId
            }
            else 
            {
                $isadmin = "N\A"
            }

            #Check Service Account
            if ($svcAcctGroupId)
                {
                    $isServiceAccount = isSvcAcct -svcAccts $svcAccountIds -userId $userId
                }   
                else   
                {
                    $isServiceAccount = $false
                }                  

                
                

                ###check is Local
            if ($localGroupId)
                {
                    
                    $isLocal = isLocal -localUsers $LocalUsers -userId $userId
                }
            else 
                {
                    <#Check if Federated Id has a Value.  Typical value is something 
                    Like YCqviKocof/+7pmCk6IXdayQzerT2v5t1NozqEV2l+I= . If Federated there would be a Value afte rth = sign #>
                
                    if (!$user.federated_id.Split("=")[1] )
                        {
                            $isLocal = $true
                        }
                    else 
                        {
                            $isLocal = $false
                        }

                }
                
            
                if(($isAdmin -eq $true -or $isServiceAccount -eq $true ) -and $isLocal -eq $true )
                {   
                
                    $Username = $user.user_name
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
                    
                    $foundAccounts += $object
                    
                    

                }
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
Add-Content -Path "c:\temp\results.txt" -Value $foundAccounts
return $foundAccounts


