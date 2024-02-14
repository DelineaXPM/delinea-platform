#Expected Argumnts @("Privileged User Name","Privileged User Password", "Instance URL", "SF Client iD","clientSecret" , "admin Role Profiles","Service account Profiles"  )
[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12


#region Set Paramaters and Vaeiables
$baseUrl = $args[2]
$tokenUrl = "$baseUrl/services/oauth2/token"
$api = "$baseUrl/services"
$clientId = $args[3]
$clientSecret = $args[4]
$username = $args[0]
$password = $args[1]
$adminCriterea = $args[5]
$adminProfileArray = $adminCriterea.split(",")
$svcactCriterea = $args[6]
$svcActProfileArray = $svcactCriterea.split(",")
$global:results = @()


#Script Constants

[string]$LogFile = "$env:Program Files\Thycotic Software Ltd\Distributed Engine\log\Salesforce-Password_Rotate.log"
[int32]$LogLevel = 3
[string]$logApplicationHeader = "Salesforce Password Change"
$foundAccounts = @()
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

#region Get Bearer Token
# Create a hashtable with the request parameters
$tokenParams = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    username = $username
    password = $password
}

# Send a POST request to obtain an access token
$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams

# Extract access token from the token response JSON
$accessToken = $tokenResponse.access_token
#endregion

#region Main Script Dunctions
function Get_Users{

try
    {
        Write-Log -ErrorLevel 0 -Message "Starting Main get User function Failed"
         $Headers = @{}
         $Headers.Add('Authorization', ("Bearer {0}" -f $AccessToken))
         $Headers.Add('Content-Type', 'application/json')
        
       
        
        $url = "$api/data/v55.0/query?q=SELECT+id+,+username+,+profile.name+,+Name+,+UserRole.Name+FROM+User" 
        #$url = "$api/data/v55.0/query/q=SELECT+id+FROM+User+where+(username='rroca66@delinea.com'"
        $users = Invoke-RestMethod -Uri $url -Headers $Headers
        $foundAccounts = @()
        foreach ($user in $users.records)
        {
            #for Demo Only
            $UserName = $user.name
            #$profile = $user.profile.name
            #$role = $user.UserRole.name
             
            #$value = "User: $UserName Profile: $profile Role : $role" 
            #Write-Host $value
            #end Demo Code
            if($user.profile -ne $null)
            {
            $isAdmin = Check_Admin_Profiles -user $user
            $isServiceAccount = Check_SvcAct_Profiles -user $user
            
                   
                        
               if($isAdmin -eq $true -or $isServiceAccount -eq $true)
                { 
                    $username =$user.username


                       
                        $object = New-Object -TypeName PSObject
                        $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL
                        $object | Add-Member -MemberType NoteProperty -Name username -Value $username
                        $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                        $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                        $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                        
                        $foundAccounts += $object
                }
            }
        }
    }

Catch
    {

        $Err = $_
         Write-Log -ErrorLevel 0 -Message "Main get User function Failed"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 

    }
return $foundAccounts    
}
function Check_Admin_Profiles
    {
        param
        (
            
        [Parameter(Mandatory=$true, HelpMessage="User object ofr a single user")]
        [System.Object]$User

        )
        
        try
        {


            $result = $false
            foreach ($profile in $adminProfileArray)
            {
                $profileTrim = $profile.Trim()
                $userProfile = $user.Profile.Name.trim()
                
                
                    if($profileTrim -eq $userProfile)
                    {
                        $result = $true
                        break
                    }

                
                }
            
        }
        catch
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "check for Admin Account  function Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception 

        }
    return $result
    }
function Check_SvcAct_Profiles
    {
        param
        (
            [Parameter(Mandatory=$true, HelpMessage="User object ofr a single user")]
            [System.Object]$User
            

        )
        
        try
        {
            

            $result = $false
            foreach ($profile in $svcactProfileArray)
            {
                $profileTrim = $profile.Trim()
                $userProfile = $user.Profile.Name.trim()
                
                
                    if($profileTrim -eq $userProfile)
                    {
                        $result = $true
                        break
                    }

                
                }
            
        }
        catch
        {
            $Err = $_
            Write-Log -ErrorLevel 0 -Message "check for Service Account  function Failed"
            Write-Log -ErrorLevel 2 -Message $Err.Exception
            throw $Err.Exception 

        }
    return $result
    }
#endregion    
# Main Process
$foundAccounts = Get_Users

return $foundAccounts 