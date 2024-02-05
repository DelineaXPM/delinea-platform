function Get-MicrosoftPlaformToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$clientId,
        [Parameter(Mandatory)]
        [string]$clientSecret,
        [Parameter(Mandatory)]
        [string]$tenantid,
        [Parameter(Mandatory=$false)]
        [string]$url="https://login.microsoftonline.com/$($tenantid)/oauth2/v2.0/token",
        [Parameter(Mandatory=$false)]
        [string]$scope="https://graph.microsoft.com/.default"
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", 'application/x-www-form-urlencoded')
    $body = @{
        client_id = $clientid
        client_secret = $client_secret
        grant_type = "client_credentials"
        scope = $scope
    } | ConvertTo-Json
    return $(Invoke-RestMethod -Uri $url -Method POST -headers $headers  -Body "grant_type=client_credentials&scope=$scope&client_id=$clientId&client_secret=$clientsecret").access_token
}

function Get-AzureDatabricksToken {
    param (
        #
    )
    
}