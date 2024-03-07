<#
    .SYNOPSIS
    Okta Local Account Discovery.
    
    .DESCRIPTION
    This script will Discover local accounts as determind by the parameters sent from the Privileged Account Secret.

#>


# Expected Arguments @( $[1]$Tenant-url $[1]$client-id $[1]$Key-ID  $[1]$Private-Key $[1]$Service-Account-Attributes $[1]$Admin-Roles)


#region Define Script Arguments

#Define Argument Variables
$oktaDomain = $args[0]
$clientId = $args[1]
$Kid = $args[2] 
$privateKeyPEM = $args[3]
$attributes = $args[4]
$attributeArray = $attributes.Split(",")
$roles = $args[5]
$rolesAray = $roles.split(",")

#Script Constants
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Okta-Discovery.log"
[int32]$LogLevel = 2
[string]$logApplicationHeader = "Okta Discovery"
[string]$scope = "okta.roles.read"
$global:foundAccounts = @()
[int32]$rateLimit = 70
$headers = ""

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


#region Script Functions
function Set-RSASignatureFromPEMString {
    param (
        [Parameter(Mandatory=$true, HelpMessage="RSA String from client in okta tenant is needed.")]
        [System.String]$RSAKey
    )

    $pemContent = $privateKeyPEM -replace '^-----[^-]+-----', '' -replace '-----[^-]+-----$', ''
    $pemContent = $pemContent -replace '\n', '' -replace '\r', ''
  
    $decodedBytes = [Convert]::FromBase64String($pemContent)
    $cngKey = [System.Security.Cryptography.CngKey]::Import($decodedBytes, [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
    return [System.Security.Cryptography.RSACng]::new($cngKey)
}
function Get-OktaJWT {
    param (
        [System.String]$oktaDomain,
        [System.String]$clientId,
        [System.String]$Kid
    )
    $header = @{
        "alg" = "RS256"
        "kid"= $Kid
    }
    $payload = @{
        "aud" = "$oktaDomain/oauth2/v1/token"
        "iss"=  $clientId
        "sub" = $clientId
        "exp" = [Math]::Floor((Get-Date).ToUniversalTime().AddHours(1).Subtract((Get-Date "1970-01-01")).TotalSeconds)# Token expires in 1 hour
        "jti" = [Guid]::NewGuid().ToString()
    }

    $encodedPayload = ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress))).`
    Trim()).`
    Replace('+', '-').`
    Replace('/', '_').`
    TrimEnd('=').Trim()
    $encodedHeader = ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($header | ConvertTo-Json -Compress))).Trim()).Replace('+', '-').Replace('/', '_').TrimEnd('=').Trim()
    $encodedToken = "$encodedHeader.$encodedPayload"
    $dataToSign = [System.Text.Encoding]::UTF8.GetBytes($encodedToken)
    $rsaSignature = $(Set-RSASignatureFromPEMString -RSAKey $privateKeyPEM).SignData($dataToSign, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    $encodedSignature = [Convert]::ToBase64String($rsaSignature)
    $encodedSignature = $encodedSignature.Replace('+', '-').Replace('/', '_').TrimEnd('=')
    $jwt = "$encodedHeader.$encodedPayload.$encodedSignature"
    return [System.String]$jwt
}
function Get-OktaBearerToken {
    param (
        [Parameter(Mandatory=$true, HelpMessage="JWT needed.")]
        [System.String]$JWT,
        [Parameter(Mandatory=$true, HelpMessage="scope needed; i.e.: okta.users.read")]
        [System.String]$Scope
    )
    
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
        'Accept' = 'application/json'
    }
    $body = @{
        'grant_type' = 'client_credentials'
        'scope' = "$Scope"
        'client_assertion_type' = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        'client_assertion' = "$(Get-OktaJWT -oktaDomain $oktaDomain -clientId $clientId -Kid $Kid)"
    }
    return @(Invoke-RestMethod -Method Post -Uri "$oktaDomain/oauth2/v1/token" -Headers $headers -Body $body).access_token
}
function Check_Roles
    {
        param
        (
            $roles,
            $user

        )
        
        try
        {
            $result = $false
            foreach ($role in $roles)
            {
                foreach($definedRole in $rolesAray)
                {
                $definedRole = $definedRole.Trim()    
                if($role.type.Contains("_ADMIN") -and $rolesAray.Count  -eq 0)
                {

                    $result = $true
                    break
                }
                else 
                {
                    if($definedRole -eq $role.label)
                    {
                        $result = $true
                        break
                    }

                }
                }
            }
        }
        catch
        {
        
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Check Admin Roles Failed "
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }
    return $result
    }
function Check-LocalUsers {
    param (
        $user
    )
    try {
        if( $user.credentials.provider.type -eq "OKTA")
        {
          $isLocal = $true
        }
        else 
        {
            $isLocal = $false
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Check Local Account Failed "
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
                   

    }
    return $isLocal
}

function Scan_Users
{
param(
$allusers
)
    try
        {
        #loop through groups
        Write-Log -Errorlevel 0 -Message "Scanning for Users"
        $accessToken = Get-Token -scope "okta.roles.read"
        $Headers = @{}
        $Headers.Add('Authorization', ("Bearer {0}" -f $accessToken))
        $Headers.Add('Content-Type', 'application/json')
        $count = 0
        
        foreach($users in $allusers)
        {
            $users=$users | ConvertFrom-Json
        
            foreach($user in $users)
                {
                    if ($count -ge $rateLimit)
                    {
                        $count = 0
                        start-sleep -Seconds 70
                        $accessToken = Get-Token -scope "okta.roles.read"
                        $Headers = @{}
                        $Headers.Add('Authorization', ("Bearer {0}" -f $accessToken))
                        $Headers.Add('Content-Type', 'application/json')
                    }
                    $count++
                    $id = $user.id   
                
                    foreach($item in $attributeArray ){
                    $split = $item.split("=")
                    $attribute= $split[0]   
                    $attribute = $attribute.Trim()
                    $value = $split[1]
                    $value = $value.Trim()
                    if ($value -eq 'null'){$value = $null}
                        if($user.profile."$attribute" -eq $value)
                            {
                                $isServiceAccount = $true
                                break
                            }
                            else
                            {
                                $isServiceAccount = $false
                            }
                        }
                    
                    $uri = "$oktadomain/api/v1/users/$id/roles"
                    $roles = Invoke-RestMethod -Uri $uri -Method 'get' -Headers $Headers
                    $isAdmin =$false
                    if ($roles.count -ge 1)
                        {
                            $result = Check_Roles -roles $roles -user $user
                            if($result -eq $true)
                            {
                            $isAdmin =$true
                            }
                            else
                            {
                                $isAdmin =$false
                            }
                        }
                        
                        #create Discovery Results
                        $isLOcal = Check-LocalUsers -user $user
                        if($isAdmin -eq $true -or $isServiceAccount -eq $true)
                        {
                        $split = $user.profile.login.split('@')
                        $Domain   = $split[1]
                        $Username = $user.profile.login

                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $Username
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $isLocal
                    $object | Add-Member -MemberType NoteProperty -Name  Domain -Value $Domain
                    $global:foundAccounts += $object

                        }
                    
                }
            }
        }
    catch
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Scanning for Users Failed Failed "
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception
        }

} 
function  Get-Token {
    param (
        [Parameter(Mandatory=$true, HelpMessage="give scope")]
        [System.String]$scope
    )
    return (Get-OktaBearerToken -JWT (Get-OktaJWT -oktaDomain $oktaDomain -clientId $clientId -Kid $Kid) -Scope $scope)
}
function Get-TheCursor{
    param(
        [object]$respobj
    )

    if ($respobj.Headers.link -match '(?<=rel="self",<)(.*?)(?=>; rel="next")') {
       Write-Debug "Captured value: $($matches[0])"
    } else {
    
        return 
    }
    return $matches[0]
}
#endregion

#Begin Main Process
try{

   
    $accessToken = Get-Token -scope "okta.users.read"
   
    $Headers = @{}
    $Headers.Add('Authorization', ("Bearer {0}" -f $accessToken))
    $Headers.Add('Content-Type', 'application/json')
    $allUsers = @()
    $responseforusers = Invoke-WebRequest -Uri "$oktaDomain/api/v1/users" -Headers $headers -UseBasicParsing
    $allUsers += $responseforusers.Content
    if ('rel="next"' -match [string]::$responseforusers.Headers.link){

        $new_resp = $(Invoke-WebRequest -Uri $(Get-TheCursor -respobj $responseforusers) -Headers @{"Authorization" = "Bearer $($accessToken)";"Accept" = "application/json"} -Method Get -UseBasicParsing)
        $allUsers += $responseforusers.Content
        while('rel="next"' -match [string]::$new_resp.Headers.link){
          
            $fin_req = $(Invoke-WebRequest -Uri $(Get-TheCursor -respobj $new_resp) -Headers @{"Authorization" = "Bearer $($accessToken)";"Accept" = "application/json"} -Method Get -UseBasicParsing)
            $allUsers += $fin_req.Content
            if (!'rel="next"' -match [string]::$responseforusers.Headers.link){break}
        }
        Scan_Users -allusers $allUsers
    }
}

   
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Retrieving token failed "
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
    
}

$userCount = $global:foundAccounts.Count
Write-Log -Errorlevel 0 -Message "Discovered $userCount Okta Users"


return   $global:foundAccounts 