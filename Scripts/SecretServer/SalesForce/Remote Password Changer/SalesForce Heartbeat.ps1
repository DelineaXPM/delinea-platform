#Expected Argumnts @("Privileged User Name","Privileged User Password", "Instance URL", "SF Client iD","clientSecret" , "Secret Server Admin User Domain","Secret Server Admin User",Secret Server Admin Password","New Password"  )


$username = $args[0] #SFDC Integration Account
$password = $args[1]  #SFDC Integration Account Password
$baseUrl = $args[2]
$tokenUrl = "$baseUrl/services/oauth2/token"
$api = "$baseUrl/services"
$clientId = $args[3]
$clientSecret = $args[4]

<#
#Set Constant Varibles
$ssapi = "$SS_BaseUrl/api/v1"
$allowedDateDiff = 5 # In Minutes
#>
# Create a hashtable with the request parameters
$tokenParams = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    username = $username
    password = $password
}

<#
# for Debug Only
$value = "$Privusername $Privpassword $baseUrl $clientId $clientSecret $SSPrivilegedUserDomain $SSPrivilegedUserName $SSPrivilegedUserPassword $SS_BaseUrl $SFDCUserDomin $SFDCUserDomin $SecretID"

#>
# Send a POST request to obtain an access token
$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams

# Extract access token from the token response JSON
$accessToken = $tokenResponse.access_token
function Get_Users{

    try
        {
             $Headers = @{}
             $Headers.Add('Authorization', ("Bearer {0}" -f $AccessToken))
             $Headers.Add('Content-Type', 'application/json')
             
             #Get UserID and Last Password Change Dta
            $from = "USER"
            $where = "(Username = '$UserName')"
            $query = "SELECT ID,LastPasswordChangeDate FROM $from WHERE $where"
            $SanitisedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
            $Uri = "$api/data/v55.0/query?q=$SanitisedQuery"
            $response =Invoke-RestMethod -Uri $uri -Headers $Headers
            $userId = $response.Records[0].iD
            $uri = "$api/data/v59.0/sobjects/User/$userId/password"
            Invoke-RestMethod -Uri $uri -Headers $Headers
    
        }
    
    Catch
        {
            $message = $_
            
            Write-Error "    $message"
            exit 1
        }
    }

$userInfo = Get_Users
    # https://MyDomainName.my.salesforce.com/services/data/v59.0/sobjects/User/005Hp00000eacK6IAI/password -H "Authorization: Bearer token"

$body = @{
        loginUrl = $baseUrl
        user = $username
        password = $password
 } | ConvertTo-Json     

#Set Secret Server Headers and Create Header
try
{
    
    $ssCreds = @{
    username = $SSPrivilegedUserName
    password = $SSPrivilegedUserPassword
    grant_type = "password" 
    }


$sstoken = ""
$response = Invoke-RestMethod -Uri "$SS_BaseUrl/oauth2/token" -Method Post -Body $ssCreds 
$sstoken = $response.access_token;




$ssheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$ssheaders.Add("Authorization", "Bearer $sstoken")

}
  
catch
{
$message =  $Error[1]

Write-Error "    $message"
exit 1
}

function Get_ssLastChangDate{

    try {
      
        $getSecret = Invoke-RestMethod -Uri "$ssapi/secrets/$secretId" -Headers $ssheaders -ErrorAction Stop
        $lastChangedDate =$getSecret.items[6].itemValue 
        
}
    catch {
        $message =  $Error[1]
        Write-Error "Get_ssLastChangDate Failed  $message"
        exit 1
    }
    return $lastChangedDate
}

Get_Users
Write-Host $global:results
return $global:results
