$username = $args[0]
$newpassword = $args[1]
$api_user = $args[2]
$api_password = $args[3]

# URL needs to be changed
$secretserver_url = 'https://barakcagdas.secretservercloud.co.uk' 
$apitokenEndpoint = "oauth2/token"
# $logfile = 'c:\backup\ChangeUP.log'
# Uncomment to turn on debug 
#$debuglevel = 1


function Write-ToLog {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Message,

        [Exception]$Exception,

        [switch]$ThrowException
    )

    if (2 -eq $debuglevel) {
        Write-Host $Message
        Write-Host ($Exception | Out-String)
    }

    if ($debuglevel) {
        $datetime = Get-Date
        Out-File -Append -FilePath $logfile -InputObject "${datetime}: $Message"
        if ($Exception) {
            Out-File -Append -FilePath $logfile -InputObject "${datetime}: $($Exception | Out-String)"
        }
    }
    if ($ThrowException) {
        throw $Exception
    }
}


function Get-APIHeader 
{

    function Get-Token 
    {
        $creds = @{ 
            username   = $api_user
            password   = $api_password
            grant_type = "password"
        }
        # Get Access Token from API
        try 
        {
            $url = "$secretserver_url/$apitokenEndpoint"
            $response = Invoke-RestMethod $url -Method Post -Body $creds
            $token = $response.access_token
            
        }
        catch 
        {
            $exception = $_.Exception
            $msg = 'API Access Token could not be retrieved'
            Write-ToLog -Message $msg -Exception $exception -ThrowException
        }
        return $token
    }

    $token = Get-Token
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers
}

function Lookup-User {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[[String],[String]]]
        $Headers,

        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    $apiEndpoint = 'api/v1/users/lookup'
    $apiEndpoint += "?filter.searchText=$UserName"

    try {
        $response = Invoke-RestMethod `
            -Method Get `
            -Headers $Headers `
            -Uri "$secretserver_url/$apiEndpoint"
    }
    catch {
        $exception = $_.Exception
        $msg = "API Endpoint `"$apiEndpoint`" could not be retrieved"
        Write-ToLog -Message $msg -Exception $exception -ThrowException
    }
    Write-ToLog -Message ($response | Out-String)
    $response
}

function Get-UserIdFromUserLookUp
{
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$LookUpObject
    )
    
    $userId = $LookUpObject.records[0].id

    Write-ToLog -Message "USer lookup ID: $userId"

    if ([string]::IsNullOrEmpty($userId)) {
        $msg = 'Cannot find User in Get-UserIdFromUserLookUp() function'
        $exception = [System.Exception]::new($msg)
        Write-ToLog -Message $msg -Exception $exception -ThrowException
    }
    
    $userid
}

function Reset-UserPassword {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[[String],[String]]]
        $Headers,

        [Parameter(Mandatory=$true)]
        [int]$UserId,

        [Parameter(Mandatory=$true)]
        [string]$Password
    )

    $apiEndpoint = "api/v1/users/$UserId/password-reset"

    $body = @{
        data = @{
            password = $Password
            userId = $UserId
        }
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod `
            -Method Post `
            -Headers $Headers `
            -Uri "$secretserver_url/$apiEndpoint" `
            -Body $body `
            -ContentType 'application/json'
    }
    catch {
        $exception = $_.Exception
        $msg = "API Endpoint `"$apiEndpoint`" could not be retrieved"
        Write-ToLog -Message $msg -Exception $exception -ThrowException
    }
    $response
}

if ($debuglevel) {
    $date = Get-Date
    Write-ToLog -Message "Username: $username`n"
    Write-ToLog -Message "NewPassword: $newpassword`n"
    Write-ToLog -Message "ApiUser: $api_user`n"
    Write-ToLog -Message "ApiPassword: $api_password`n"
}

$headers = Get-APIHeader
$lookUpUserObject = Lookup-User -Headers $headers -UserName $username
$userId = Get-UserIdFromUserLookUp -LookUpObject $lookUpUserObject
$response = Reset-UserPassword -Headers $headers -UserId $userid -Password $newpassword
Write-ToLog -Message ($response | Out-String)
$true