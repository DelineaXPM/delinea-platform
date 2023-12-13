# $PASSWORD $[1]$USERNAME $[1]$PASSWORD $LINKED

$token = ""

$site = "https://SecretServerURL/"
$api = "$site/api/v1"
$tokenroute = "$site/oauth2/token"
$newpassword = $args[0]
$apiusername = $args[1]
$apipassword = $args[2]
$linked = $args[3]

$creds = @{
        username = $apiusername
        password = $apipassword
        grant_type = "password"
        }

$response = Invoke-RestMethod "$tokenroute" -Method Post -Body $creds
$token = $response.access_token;

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")

$inputsecrets = $linked.Split(",")

$data = @{
    value = $newpassword
}| ConvertTo-Json

for ( $i = 0; $i -lt $inputsecrets.Length; $i++ ) 
{
try
        {
                $secretid = $inputsecrets[$i]
        } catch {
                throw $_
        }
        
        if($secretid)
        {   
                Invoke-RestMethod $api"/secrets/$secretid/fields/password" -Method PUT -ContentType application/json -Body $data -Headers $headers
        } else {
                throw "Null value for Secret ID ($secretid)"
        }
}