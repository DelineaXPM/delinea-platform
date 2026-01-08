# Expected Args args=@("Discovery Mode Advanced/Default","Service Now Tenant Base URL",SNOW Privileged Username","SNOW Privileged Password","SNOW Client ID","SNOW Client Secret" ,"Private Key" ,"Admin Role ID","Local Group ID"  )

#region Log Configuration
# Log settings - modify these values as needed
[string]$logFolder = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log"
[string]$LogFile = "$logFolder\ServiceNow-Discovery.log"
[string]$ResultsFile = "$logFolder\ServiceNow-Discovery-Results.json"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "ServiceNow Discovery"
#endregion Log Configuration

#region Define Variables
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

#Script Constants
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
        [string]$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INFO " }
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

#region Helper Functions
function Test-PlaceholderValue {
    param(
        [string]$Value,
        [string]$PlaceholderKeyword,
        [string]$ParameterName
    )
    if ($Value.StartsWith('$') -and $Value -match $PlaceholderKeyword) {
        Write-Log -ErrorLevel 2 -Message "Invalid parameter '$ParameterName': Value appears to be an unsubstituted placeholder ('$Value')"
        throw "Parameter '$ParameterName' contains an unsubstituted placeholder value. Please check Secret Server configuration."
    }
}

function Get-TruncatedSecret {
    param(
        [string]$Secret,
        [int]$Length = 5
    )
    if ([string]::IsNullOrEmpty($Secret)) {
        return "[empty]"
    }
    if ($Secret.Length -le $Length) {
        return "$Secret***"
    }
    return "$($Secret.Substring(0, $Length))***"
}

function Get-SanitizedHeaders {
    param(
        [hashtable]$Headers
    )
    $sanitized = @{}
    foreach ($key in $Headers.Keys) {
        if ($key -eq "Authorization") {
            $sanitized[$key] = "Bearer [REDACTED]"
        } else {
            $sanitized[$key] = $Headers[$key]
        }
    }
    return ($sanitized | ConvertTo-Json -Compress)
}

function Write-ApiCallLog {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [object]$Body = $null
    )
    Write-Log -ErrorLevel 3 -Message "API Call: $Method $Uri"
    Write-Log -ErrorLevel 3 -Message "Headers: $(Get-SanitizedHeaders -Headers $Headers)"
    if ($Body) {
        $sanitizedBody = $Body.Clone()
        if ($sanitizedBody.ContainsKey('password')) {
            $sanitizedBody['password'] = Get-TruncatedSecret -Secret $sanitizedBody['password']
        }
        if ($sanitizedBody.ContainsKey('client_secret')) {
            $sanitizedBody['client_secret'] = Get-TruncatedSecret -Secret $sanitizedBody['client_secret']
        }
        Write-Log -ErrorLevel 3 -Message "Body: $($sanitizedBody | ConvertTo-Json -Compress)"
    }
}
#endregion Helper Functions

#region Log Input Parameters
Write-Log -ErrorLevel 3 -Message "=== Script Parameters ==="
Write-Log -ErrorLevel 3 -Message "DiscoveryMode: $DiscoveryMode"
Write-Log -ErrorLevel 3 -Message "baseURL: $baseURL"
Write-Log -ErrorLevel 3 -Message "username: $username"
Write-Log -ErrorLevel 3 -Message "password: $(Get-TruncatedSecret -Secret $password)"
Write-Log -ErrorLevel 3 -Message "clientId: $clientId"
Write-Log -ErrorLevel 3 -Message "clientSecret: $(Get-TruncatedSecret -Secret $clientSecret)"
Write-Log -ErrorLevel 3 -Message "adminRole: $adminRole"
Write-Log -ErrorLevel 3 -Message "svcAcctGroupId: $svcAcctGroupId"
Write-Log -ErrorLevel 3 -Message "localGroupId: $localGroupId"
Write-Log -ErrorLevel 3 -Message "========================="
#endregion Log Input Parameters

#region Validate Input Parameters
Write-Log -ErrorLevel 0 -Message "Validating input parameters"

# Validate DiscoveryMode
if ($DiscoveryMode -notin @('Advanced', 'Default')) {
    Write-Log -ErrorLevel 2 -Message "Invalid DiscoveryMode: '$DiscoveryMode'. Must be 'Advanced' or 'Default'"
    throw "Invalid DiscoveryMode: '$DiscoveryMode'. Must be 'Advanced' or 'Default'"
}

# Validate baseURL starts with https://
if (-not $baseURL.StartsWith('https://')) {
    Write-Log -ErrorLevel 2 -Message "Invalid baseURL: '$baseURL'. Must start with 'https://'"
    throw "Invalid baseURL: '$baseURL'. Must start with 'https://'"
}

# Validate required parameters are not unsubstituted placeholders
Test-PlaceholderValue -Value $username -PlaceholderKeyword 'username' -ParameterName 'username'
Test-PlaceholderValue -Value $password -PlaceholderKeyword 'pass' -ParameterName 'password'
Test-PlaceholderValue -Value $clientId -PlaceholderKeyword 'client' -ParameterName 'clientId'
Test-PlaceholderValue -Value $clientSecret -PlaceholderKeyword 'client' -ParameterName 'clientSecret'

# Validate optional parameters if provided
if ($adminRole) {
    Test-PlaceholderValue -Value $adminRole -PlaceholderKeyword 'role' -ParameterName 'adminRole'
}
if ($svcAcctGroupId) {
    Test-PlaceholderValue -Value $svcAcctGroupId -PlaceholderKeyword 'group' -ParameterName 'svcAcctGroupId'
}
if ($localGroupId) {
    Test-PlaceholderValue -Value $localGroupId -PlaceholderKeyword 'local' -ParameterName 'localGroupId'
}

Write-Log -ErrorLevel 0 -Message "Input parameters validated successfully"
#endregion Validate Input Parameters

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
    # Log API call (token endpoint - no auth header yet)
    Write-Log -ErrorLevel 3 -Message "API Call: POST $tokenUrl"
    Write-Log -ErrorLevel 3 -Message "Body: grant_type=password, client_id=$clientId, client_secret=$(Get-TruncatedSecret -Secret $clientSecret), username=$username, password=$(Get-TruncatedSecret -Secret $password), scope=$scope"

    # Make a POST request to obtain the token
    $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body

    # Extract the access token from the response
    $accessToken = $response.access_token
    
    Write-Log -Errorlevel 0 -Message "Access Token Successfully Obtained "

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
function Test-IsAdminUser {
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
function Test-IsServiceAccount {
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
function Test-IsLocalUser {
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

    # Log API call
    Write-ApiCallLog -Method $method -Uri $uri -Headers $headers

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
function Get-AdminUsers {
    try {
        Write-Log -Errorlevel 0 -Message "Retrieving  List of Admin Users"       
        ##Create Roles Array
      
        If ($adminRole)
        {
            ### Create Array of Admin Roles
            
            #Clear Parameter List
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
                # Log API call
                Write-ApiCallLog -Method "GET" -Uri $uri -Headers $headers
                $adminUsers = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
                Write-Log -ErrorLevel 0 -Message "Successfully found $($adminUsers.result.Count) Admin Accounts"    
                

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
function Get-ServiceAccounts {
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
                # Log API call
                Write-ApiCallLog -Method "GET" -Uri $uri -Headers $headers
                $svcAccountIds = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
                Write-Log -ErrorLevel 0 -Message "Successfully found $($svcAccountIds.result.Count) Service Accounts"  
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

#region Get Local Users
function Get-LocalUsers {
    try{ 

    
        #Check if GroupID Provided
       If ($localGroupId)
       {
            
            # Specify endpoint uri
            $uri = "$api/table/sys_user_grmember?sysparm_query=group=$localGroupId"

            # Specify HTTP method
            $method = "get"

            # Log API call
            Write-ApiCallLog -Method $method -Uri $uri -Headers $headers

            # Send HTTP request
            $LocalUsers= Invoke-RestMethod -Headers $headers -Method $method -Uri $uri
            Write-Log -ErrorLevel 0 -Message "Successfully found $($LocalUsers.result.Count) Local Accounts"  
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

  $adminUsers = Get-AdminUsers
  $svcAccountIds = Get-ServiceAccounts

}
$LocalUsers = Get-LocalUsers
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
                    
                    $isLocal = Test-IsLocalUser -localUsers $LocalUsers -userId $userId
                }
            else 
                {
                    <#ServiceNow note Check if Federated Id has a Value.  Typical value is something 
                    Like YCqviKocof/+7pmCk6IXdayQzerT2v5t1NozqEV2l+I= . If Federated there would be a Value after the = sign #>
                  
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
                    $object | Add-Member -MemberType NoteProperty -Name host -Value $baseURL
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                    
                    $foundAccounts += $object
                    
                }
            }
        }
    else{
        foreach ($user in $users.result)
        {
            $user
            
            
            ### check if is admin
            if($adminRole) 
            {
                $isadmin = Test-IsAdminUser -adminUsers $adminUsers -userId $userId
            }
            else 
            {
                $isadmin = "N\A"
            }

            #Check Service Account
            if ($svcAcctGroupId)
                {
                    $isServiceAccount = Test-IsServiceAccount -svcAccts $svcAccountIds -userId $userId
                }   
                else   
                {
                    $isServiceAccount = $false
                }                  

                
                

                ###check is Local
            if ($localGroupId)
                {
                    
                    $isLocal = Test-IsLocalUser -localUsers $LocalUsers -userId $userId
                }
            else 
                {
                    <#Check if Federated Id has a Value.  Typical value is something 
                    Like YCqviKocof/+7pmCk6IXdayQzerT2v5t1NozqEV2l+I= . If Federated there would be a Value after the = sign #>
                
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
                    $object | Add-Member -MemberType NoteProperty -Name host -Value $baseURL
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

# Write results to JSON file
Write-Log -ErrorLevel 0 -Message "Writing $($foundAccounts.Count) discovered accounts to $ResultsFile"
$foundAccounts | ConvertTo-Json -Depth 10 | Out-File -FilePath $ResultsFile -Encoding utf8 -Force
Write-Log -ErrorLevel 0 -Message "Discovery completed successfully"

return $foundAccounts


