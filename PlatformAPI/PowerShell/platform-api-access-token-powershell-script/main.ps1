# Import configuration variables
. .\config.ps1

$global:ACCESS_TOKEN = $null
$global:REFRESH_TOKEN = $null
$global:TOKEN_EXPIRES_AT = 0

function Get-InitialTokens {
    $global:ACCESS_TOKEN
    $global:REFRESH_TOKEN
    $global:TOKEN_EXPIRES_AT

    $payload = @{
        grant_type = $GRANT_TYPE
        client_id = $CLIENT_ID
        client_secret = $CLIENT_SECRET
        scope = $SCOPE
    }

    try {
        $response = Invoke-RestMethod -Uri $TOKEN_URL -Method Post -Body $payload
        if ($response) {
            $global:ACCESS_TOKEN = $response.access_token
            $global:REFRESH_TOKEN = $response.refresh_token
            $expires_in = $response.expires_in
            $global:TOKEN_EXPIRES_AT = (Get-Date).AddSeconds($expires_in).AddMinutes(-1)

            Write-Host "Initial Access Token Obtained"
            Write-Host "Access Token: $global:ACCESS_TOKEN"
            if ($global:REFRESH_TOKEN) {
                Write-Host "Refresh Token: $global:REFRESH_TOKEN"
            }
        }
    } catch {
        Write-Host "Failed to Obtain Initial Tokens"
        Write-Host $_.Exception.Message
    }
}

function Get-NewAccessToken {
    $global:ACCESS_TOKEN
    $global:TOKEN_EXPIRES_AT
    $global:REFRESH_TOKEN

    $headers = @{
        Authorization = "Bearer $global:ACCESS_TOKEN"
    }
    $payload = @{
        grant_type = $REFRESH_GRANT_TYPE
        refresh_token = $global:REFRESH_TOKEN
    }

    try {
        $response = Invoke-RestMethod -Uri $TOKEN_URL -Method Post -Body $payload -Headers $headers
        if ($response) {
            $global:ACCESS_TOKEN = $response.access_token
            $expires_in = $response.expires_in
            $global:TOKEN_EXPIRES_AT = (Get-Date).AddSeconds($expires_in).AddMinutes(-1)

            Write-Host "New Access Token Obtained"
            Write-Host "Access Token: $global:ACCESS_TOKEN"
            if ($response.refresh_token) {
                $global:REFRESH_TOKEN = $response.refresh_token
                Write-Host "Refresh Token: $global:REFRESH_TOKEN"
            }
        }
    } catch {
        Write-Host "Failed to Refresh Token"
        Write-Host $_.Exception.Message
    }
}

function Ensure-ValidToken {
    if ((Get-Date) -gt $global:TOKEN_EXPIRES_AT) {
        Write-Host "Access Token Expired"
        Write-Host "Refreshing..."
        Get-NewAccessToken
    } else {
        Write-Host "Access Token is Still Valid"
    }
}

function Call-API {
    $headers = @{
        Authorization = "Bearer $global:ACCESS_TOKEN"
    }

    try {
        $response = Invoke-RestMethod -Uri $API_URL -Method Get -Headers $headers
        if ($response) {
            Write-Host "API Call Successful"
            Write-Host ($response | ConvertTo-Json -Depth 4)
        }
    } catch {
        Write-Host "API Call Failed"
        Write-Host $_.Exception.Message
    }
}

# Main script execution
Write-Host "Starting Token Acquisition"
Get-InitialTokens
Ensure-ValidToken
Call-API
