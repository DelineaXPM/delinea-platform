#ARGUMENTS $[1]$apiurl $[1]$ApplicationID $[1]$ApplicationSecret $OrganizationID $emailaddress $newpassword
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$APIBaseUrl = $args[0]
if ($APIBaseUrl -notlike 'https://*' ) { Throw "Associated Secret Not Found - API URL $($args[0])" }

$ApplicationID = $args[1]
$ApplicationSecret = $args[2]
$OrganizationID = $args[3]

$email = $args[4]
$NewPassword = $args[5]

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (compatible; Delinea/PrivOtter; +http://www.delinea.com)" 
try {
    $AccessToken = (Invoke-RestMethod -Method POST -Uri "$($APIBaseUrl)/v2/organizations/$OrganizationID/application-token" -Headers @{"Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ApplicationID):$($ApplicationSecret)")))"; "Content-Type" = "application/x-www-form-urlencoded" } -Body "grant_type=client_credentials&user_email=$email" -ErrorAction Stop).access_token
}
catch { throw "Error in authentication: $_" }
try {
    $user = Invoke-RestMethod -UseBasicParsing -Method GET -Uri "$($APIBaseUrl)/_ah/api/lumsites/v1/user/get?email=$($email)" -WebSession $session -Headers @{
        "accept"                  = "application/json"
        "authorization"           = "Bearer $AccessToken"
        "lumapps-organization-id" = $OrganizationID
    } 
}
catch { throw "Error in user lookup: $_" }

$body = New-Object psobject -Property @{
    customer    = $OrganizationID;
    id          = $user.id;
    loginId     = $user.loginId;
    accountType = "external";
    password    = $NewPassword;
    rePassword  = $NewPassword;
}

try {
    $Result = Invoke-RestMethod -UseBasicParsing -Method POST -Uri "$($APIBaseUrl)/_ah/api/lumsites/v1/user/save" `
        -WebSession $session `
        -Headers @{
        "accept"                  = "application/json"
        "authorization"           = "Bearer $AccessToken"
        "lumapps-organization-id" = $OrganizationID
        "user_email"              = $email
    } `
        -ContentType "application/json;charset=UTF-8" `
        -Body ($body | ConvertTo-Json -Depth 10) 
}
catch { Write-Error "Error Updating password: $_" }



