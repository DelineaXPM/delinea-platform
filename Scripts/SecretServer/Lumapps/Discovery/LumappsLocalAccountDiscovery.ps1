#ARGUMENTS $[1]$apiurl $[1]$ApplicationID $[1]$ApplicationSecret $target $[1]$email $[1]$BaseURL
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$APIBaseUrl = $args[0]
if ($APIBaseUrl -notlike 'https://*' ) { Throw "Associated Secret Not Found - API URL $($args[0])" }

$ApplicationID = $args[1]
$ApplicationSecret = $args[2]
$OrganizationID = $args[3] -replace "ou=",""
$Email = $args[4]
if ($Email -notlike '*@*.*' ) { Throw "Associated Secret Email missing" }

$BaseURL = $args[5]

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (compatible; Delinea/PrivOtter; +http://www.delinea.com)" 

$AccessToken = (Invoke-RestMethod -Method POST -Uri "$($APIBaseUrl)/v2/organizations/$OrganizationID/application-token" -Headers @{"Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ApplicationID):$($ApplicationSecret)")))"; "Content-Type" = "application/x-www-form-urlencoded" } -Body "grant_type=client_credentials&user_email=$email" -ErrorAction Stop).access_token

$Result = Invoke-RestMethod -UseBasicParsing -Method POST -Uri "$($APIBaseUrl)/_ah/api/lumsites/v1/user/directory/list" `
    -WebSession $session `
    -Headers @{
    "accept"                  = "application/json"
    "authorization"           = "Bearer $AccessToken"
    "lumapps-organization-id" = $OrganizationID
} -ContentType "application/json;charset=UTF-8" `
    -Body "{`"maxResults`":1000,`"more`":true,`"lang`":`"en`",`"contentId`":`"6287474483527680`",`"profileCriteria`":{`"feeds`":[]}}"
    

#available values "accountType","alternateEmail","apiProfile","canAccessSA","changePasswordAtNextLogin","createdAt","customer","customProfile","email","employeeId","expirationDate","externalDirectoryUrl","federationValue","firstName","fullName","id","identityProvider","instancesSuperAdmin","isDesigner","isGod","isHidden","isSuperAdmin","lang","langs","lastName","lastSynchronization","loginId","loginProvider","profileId","profilePicture","profilePictureUrl","profileStatus","properties","settings","socialAdvocacyPermissions","socialNetworkAccesses","status","subscriptions","synchronized","tutorials","uid","unifiedProfileId","unreadNotificationCount","updatedAt","url"

$accounts = $Result.items | Where-Object isHidden -EQ $false | Select-Object @{Name="EmailAddress";E={$_.email}}, fullName, isSuperAdmin, @{Name="URL";Expression={$BaseURL}},@{Name="OrganizationID";Expression={$OrganizationID}}

return $accounts
