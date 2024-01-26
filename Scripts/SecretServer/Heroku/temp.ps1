$apikey ="6b4404e1-4d5e-4af9-9d31-7ab44e8eaf02"
$TeamNAme = "workdayintegrations"
$url = "https://api.heroku.com/teams/$TeamNAme/members"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", 'application/json')
$headers.Add("Authorization", "Bearer $apikey")
$headers.Add("Accept", "application/vnd.heroku+json; version=3")

Invoke-RestMethod -uri $url -Headers $headers