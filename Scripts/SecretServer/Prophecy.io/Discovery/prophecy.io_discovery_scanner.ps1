#ARGUMENTS :$[1]$resource $[1]$password $[1]$notes

[uri]$APIUrl = $args[0]
$token = $args[1]
$teamlist = $args[2]

$APIUrl = "https://app.prophecy.io/api/md/graphql"
$token = Import-Clixml ~\prophecy.clixml
$teamlist = "andrew.schilling@delinea.com_team", "rob.jagger@delinea.com_team"


$headers = @{
    "accept"       = "application/json"
    "x-auth-token" = $token
}
[array]$collection = ""
[array]$RetrunUsers = ""

foreach ($teamname in $teamlist) {
    $body = '{"query":"query Team {\n    Team(name: \"' + $teamname + '\") {\n        _id\n        name\n        members {\n            _id\n            name\n            email\n        }\n    }\n}\n","operationName":"Team","variables":{}}'
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (compatible; Delinea/PrivOtter; +http://www.delinea.com)" 
    $collection += (Invoke-RestMethod -UseBasicParsing -Method POST -Uri $apiurl -WebSession $session -Headers $headers -ContentType "application/json;charset=UTF-8" -Body $body).data.team
}


$allusers = $collection.members.email | Sort-Object -Unique

foreach ($email in $allusers) {
    $item = New-Object -TypeName PSCustomObject -Property @{"EmailAddress" = $email; "groups" = $null ; "ProphecyUserID" = ($collection.members | Where-Object -FilterScript { $_.email -eq $email })[0]._id }
    foreach ($index in 0..($collection.count - 1)) {
        if ($collection[$index].members.email -contains $email) { $item.groups = ($collection[$index].name, $item.groups -join ",").trim(",") }
    }
    $RetrunUsers += $item
}

$RetrunUsers