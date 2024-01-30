
#Expected Argumnts @("username", "password", "clientId", "clientSecret", "kid", "tenant", "privuseremail", "privateKeyPEM")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Expected Argumnts @("Privileged User Name","Privileged User Password", "Instance URL", "SF Client iD","clientSecret" ,"SFDC UserName","SFDC User Domain" ,"New Password"  )

#region Set Paramaters and Vaeiables
$Privusername = $args[0]
$Privpassword = $args[1]
$baseUrl = $args[2]
$tokenUrl = "$baseUrl/services/oauth2/token"
$api = "$baseUrl/services"
$clientId = $args[3]
$clientSecret = $args[4]
$SFDCUserName = $args[5]
$newPassword = $args[6]


#Script Constants

[string]$LogFile = "$env:Program Files\Thycotic Software Ltd\Distributed Engine\log\ServiceNow-Password_Rotate.log"
[string]$LogFile = "c:\temp\Salesforce.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Salesforce Password Change"

#endregion

#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,1,2,3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message
    )
    # Evaluate Log Level based on global configuration
    if ($ErrorLevel -le $LogLevel) {
        # Format message
        [string]$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm:sszzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        # Write Log data
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel,$logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
        # $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        # Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}
#endregion Error Handling Functions

#region Get Access Token
#Create a hashtable with the request parameters
$tokenParams = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    username = $Privusername
    password = $Privpassword
}
<# ********* #for Debug Only************************
$value = "$Privusername $Privpassword $baseUrl $clientId $clientSecret $SFDCUserName $SFDCUserDomin  $newPassword"  
Add-Content -Path "c:\temp\salesForce.txt" -Value $value
#>

#region Get access Token
try {
    Write-Log -ErrorLevel 0 -Message "Obtaining Access Token"
    # Send a POST request to obtain an access token
$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams

# Extract access token from the token response JSON
$accessToken = $tokenResponse.access_token
}

catch {
    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Obtaining Access Token Failed"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception     
}
#endregion

function Change_Password{

try
    {
        Write-Log -ErrorLevel 0 -Message "Attempting Password change"
         $Headers = @{}
         $Headers.Add('Authorization', ("Bearer {0}" -f $AccessToken))
         $Headers.Add('Content-Type', 'application/json')
         $SFDCuserId = Get_UserId
         $body = @{
                    NewPassword = $newPassword

                 }
        $payload = $body | ConvertTo-Json
        $uri ="$api/data/v58.0/sobjects/User/$SFDCuserId/password"
        Invoke-RestMethod -Uri $uri -Method Post -Headers $Headers -Body $payload -ContentType "application/json" 
        

    }
  
Catch
    {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Password change Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
}
function Get_UserId{

    try
        {
            Write-Log -ErrorLevel 0 -Message "Finding User ID"   
             $Headers = @{}
             $Headers.Add('Authorization', ("Bearer {0}" -f $AccessToken))
             $Headers.Add('Content-Type', 'application/json')
             
             #Get UserID and Last Password Change Dta
            $from = "USER"
            $where = "(Username = '$SFDCUserName')"
            $query = "SELECT ID FROM $from WHERE $where"
            $SanitisedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
            $Uri = "$api/data/v55.0/query?q=$SanitisedQuery"
            $response =Invoke-RestMethod -Uri $uri -Headers $Headers
            $SFDCuserId = $response.records[0].id
            
    
        }
    
    Catch
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "Get userID Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception 
        }
        return $SFDCuserId
    }

Change_Password

return $result

