# This is a REST based replacement for the SOAP script at the bottom of 
# https://docs.delinea.com/online-help/secret-server/rpc-heartbeat/rpc/rpc-shared-secrets/index.htm

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ServerURL = "https://SecretServerBasePath/"

$APIUser = $args[0]
$APIUserPassword = $args[1]
$SecretPassword = $args[2]
$SecretList = $Args[3].split(",")
$APIUserDomain = $args[4]

#if you need more verbose errors change this to $true and make sure the file path exists
$debug = $false
$errorfile = "c:\temp\secretDependencyUpdateFailures.csv"

if ($null -eq $APIUserDomain -or $APIUserDomain -eq "local") {
        $creds = @{
                username   = $APIUser
                password   = $APIUserPassword
                grant_type = "password"
        }
}
else {
        $creds = @{
                username   = $APIUserDomain, $APIUser -join "\"
                password   = $APIUserPassword
                grant_type = "password"
        }
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

try {
        $APIToken = Invoke-RestMethod ($serverurl + 'oauth2/token') -Method 'POST' -Headers $headers -Body $creds | Select-Object -ExpandProperty access_token
        if ($debug) { (Get-Date).ToString(), "Connected to API: ", ($serverurl + 'oauth2/token') -join "`t" | Out-File -FilePath $errorfile -Append }
}
catch {
        Write-Error "Error logging into server $serverurl : $_" 
        if ($debug) { (Get-Date).ToString(), "Bad login attempt: ", ($serverurl + 'oauth2/token'), $body, $_ -join "`t" | Out-File -FilePath $errorfile -Append }
        return
}

$headers.Add("Authorization", "Bearer " + $APIToken)
$body = @{ "newPassword" = $SecretPassword }
[array]$errorlist = @()
foreach ($SecretID in $SecretList) {
        try {
                Invoke-RestMethod ( $ServerURL + 'api/v1/secrets/' + $SecretID + '/change-password') -Method 'POST' -Headers $headers -Body ($body | ConvertTo-Json) | Out-Null
                if ($debug) { (Get-Date).ToString(), "SecretID: $secretid", "Updated Without Error" -join "`t" | Out-File -FilePath $errorfile -Append }
        }
        catch {
                $errorlist += $secretid
                if ($debug) { (Get-Date).ToString(), "SecretID: $secretid", ($_.ErrorDetails) -join "`t" | Out-File -FilePath $errorfile -Append }
        }
}
if ($errorlist.count -gt 0) { Write-Error ("error setting password on secret id(s): " + $errorlist) }
