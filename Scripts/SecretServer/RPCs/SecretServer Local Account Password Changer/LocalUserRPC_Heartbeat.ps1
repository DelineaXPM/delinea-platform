$api_user = $args[0]
$api_password = $args[1]

# URL needs to be changed
$secretserver_url = 'https://barakcagdas.secretservercloud.co.uk/' 
$apitokenEndpoint = "oauth2/token"
$logfile = '.\Folders.log'
# Uncomment to turn on debug 
#$debuglevel = 1

function Write-ToLog {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Message,

        [Exception]$Exception,

        [switch]$ThrowException
    )

    Write-Host $Message
    Write-Host ($Exception | Out-String)

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
            throw $_.Exception
            
        }
        return $token
    }

    $token = Get-Token
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers
}

try {
    $headers = Get-APIHeader
}
catch {
    throw
}

$true