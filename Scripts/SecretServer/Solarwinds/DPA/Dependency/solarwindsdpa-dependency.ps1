$params = $args
$SqlName = $params[0] # Name of the SQL Server instance from the secret that DPA is monitoring
$NewPassword = $params[1]

$baseUrl = "http://<your SolarWinds Server name>:8123/iwc/api"
$refreshToken = "<refresh token from DPA>"

$timeoutSeconds = 60
$authToken = Invoke-RestMethod -Method POST -Uri "$baseUrl/security/oauth/token" -Body @{"grant_type" = "refresh_token"; "refresh_token" = "$refreshToken" }

$dpaHeader = @{}
$dpaHeader.Add("Accept","application/json")
$dpaHeader.Add("Content-Type","application/json;charset=UTF-8")
$dpaHeader.Add("Authorization","$($authToken.token_type) $($authToken.access_token)")

# Lookup DPA ID for the SQL Server instance being monitored
$monitorUrl = "$baseUrl/databases/monitor-information"

# Specifically comparing case insensitive (ieq) between name DPA has and name Secret Server has (just to be safe)
$monitorList = Invoke-RestMethod -Method Get -Uri $monitorUrl -Headers $dpaHeader -TimeoutSec $timeoutSeconds | Select-Object -ExpandProperty data | Where-Object Name -ieq $SqlName

$dpaId = $monitorList.dbId
$updatePwdUrl = "$baseUrl/databases/$dpaId/update-password"

$newPassword = @{"password" = "$NewPassword" } | ConvertTo-Json
try {
    Invoke-RestMethod -Method Put -Uri $updatePwdUrl -Body $newPassword -Headers $dpaHeader -TimeoutSec $timeoutSeconds | Select-Object -ExpandProperty data
} catch {
    throw "Password change not successful on $($SqlName): $($_.Exception.Message)"
}
