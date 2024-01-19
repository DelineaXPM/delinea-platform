  <#
  .SYNOPSIS
  Discover Github Local Accounts
  
  .DESCRIPTION
  This script will discover Local Accounts and Filter based on Role and Group Permissions
  Admins -In Gitub admins are determined by Having the Admin right to a Github Organization.  There is no Filtering on this option
  Service Accounts are determined by being a member of a team.  To enable this function, all service Accounts mist be part of a Team.
  .EXAMPLE
  An example
  This is an example of Args to be passed into the Script
 
  .NOTES
  General notes
  #>




#region define variables

##Define Argument Variables

[string]$AccessToken = $args[0]
[string]$Organization = $args[1]
[string]$ServiceAccountTeams = $args[2]

# Create argument Arrays

[System.Array]$ServiceAccountTeamsArray = $ServiceAccountTeams.Split(",")
[System.Array]$Global:svcAccountUsers = @()
$global:adminUsers = @()

#Script Constants

[int32]$LogLevel = 3
[string]$logApplicationHeader = "Github Discovery"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\GithubDiscovery.log"


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
  }
}
#Arg pass check:
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$AccessToken -or !$Organization ) {
    # If variables are not set, the script will stop
    Write-Log -Errorlevel 2 -Message "One or more variables are not set"
    throw "One or more variables are not set"
}

#endRegion

#region Create Headers and Queries
$StartPageQuery = @"
{
  organization(login: "$Organization") {
    membersWithRole(first: 100) {
      nodes {
        email
        name
        login
        organizationVerifiedDomainEmails(login: "$Organization")
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
"@
$headers = @{
    "Authorization" = "Bearer $AccessToken";
    "User-Agent" = "MyApp";
    "Accept" = "application/vnd.github.v3+json";
    "X-GitHub-Api-Version" = "2022-11-28";
    "Content-Type" = "application/json";
}
#endregion

#region Main Functions
function isServiceAccount{
    param (
        [System.Array]$User
      
    )
    $isServiceAcct = $false
    foreach ($svcAcctuser in $Global:svcAccountUsers)
    {
      
      if($user -eq $svcAcctuser){
            $isServiceAcct = $true
            break
          
          } 
        }
  return $isServiceAcct
}

function Get-ServiceAccounts{

  try{
    Write-Log -ErrorLevel 3 -Message "Retrieving List of Service Users"
    
    foreach($team in $ServiceAccountTeamsArray ){
        $response =  Invoke-WebRequest "https://api.github.com/orgs/$($Organization)/teams/$($team)/members"  -Method Get -Headers $headers
        $teamMembers = $response | ConvertFrom-Json
        foreach ($user in $teamMembers){
          $Global:svcAccountUsers += $user.Login
        }
    }
      
  }
  
  catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to get List of ServiceAccount Users"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
  }

}
function isadmin{
  param (
      [string]$user
    
  )
  $isAdmin = $false
  foreach ($adminUser in $global:adminUsers)
  {
    
    if($adminUser.login -eq $user){
          $isAdmin = $true
          break
        
        } 
      }
return $isAdmin
}

function Get-AdminAccounts{

    try{
      Write-Log -ErrorLevel 3 -Message "Retrieving List of Admin Users"
      $admins = @(Invoke-WebRequest "https://api.github.com/orgs/$($Organization)/members?role=admin"  -Method Get -Headers $headers| ConvertFrom-Json)
    }
    
    catch {
      $Err = $_
      Write-Log -ErrorLevel 0 -Message "Failed to get List of Admin Users"
      Write-Log -ErrorLevel 2 -Message $Err.Exception
      throw $Err.Exception
    }
    
    return $admins
}
function Get-AllGitHubUsersInOrg{
    param (
        [System.String]$Organization,
        [bool]$hasNextPage=$true
    )
    try{
      $start_user_process = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Headers $headers -Method Post -Body (@{query = $StartPageQuery}|ConvertTo-Json)
    }
    
    catch {
      $exception = New-Object System.Exception "Caught some general error`nMessage: $($_.Exception.Message)."
      Write-Log -Errorlevel 2 -Message "Caught some general error`nMessage: $($_.Exception.Message)."
      throw $exception
    }
    if($start_user_process.errors){
      Write-Log -Errorlevel 2 -Message "There was an error when getting the info`nMessage: $($start_user_process.errors.message)"
      throw New-Object System.Exception "There was an error when getting the info`nMessage: $($start_user_process.errors.message)"
    }
    $UserNodeList = @()
    $UserNodeList += @($start_user_process.data.organization.membersWithRole.nodes) #append the beginning before getting opaque cursor val
    $endCursor = $start_user_process.data.organization.membersWithRole.pageInfo.endCursor #opaque cursor val
    Write-Log -Errorlevel 0 -Message "Got Opaque cursor. Val is: $($endCursor)"
    while ($hasNextPage) {
    $graphQLQuery = @"
{
  organization(login: "$Organization") {
    membersWithRole(first: 100, after: "$endCursor") {
      totalCount
      nodes {
        email
        name
        login
        organizationVerifiedDomainEmails(login: "$Organization")
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
"@
    try{
      $response = Invoke-RestMethod -Uri 'https://api.github.com/graphql' -Headers $headers -Method Post -Body (@{query = $graphQLQuery}|ConvertTo-Json)
    }
    
    catch {
      Write-Log -Errorlevel 2 -Message "We threw up on something else: Caught some general error: $($_.Exception.Message)."
      $exception = New-Object System.Exception "We threw up on something else: Caught some general error: $($_.Exception.Message)."
      throw $exception
    }
    $hasNextPage = $response.data.organization.membersWithRole.pageInfo.hasNextPage
    $endCursor = $response.data.organization.membersWithRole.pageInfo.endCursor
    $UserNodeList += @($response.data.organization.membersWithRole.nodes)
    }
    $result = $UserNodeList | Where-Object {$_.organizationVerifiedDomainEmails -ne $null}
  return $result
}
######
#endregion

#region Main Process

# Set global onject for Service Account users
Get-ServiceAccounts
$GitHubUsers = Get-AllGitHubUsersInOrg -Organization $Organization
if ($GitHubUsers -eq $null){
  Write-Log -Errorlevel 2 -Message "No Github users. Throwing up here."
  throw New-Object System.Exception "No Github users. Throwing up here."
}
$global:adminUsers = Get-AdminAccounts
$foundAccounts = @()
foreach ($user in $GitHubUsers) 
  {
   
    $isServiceAccount = isServiceAccount -User $user.login
    $isAdmin = isadmin -User $user.login
    
    if($isAdmin -eq $true -or $isServiceAccount -eq $true ) 
                {   
                
                   
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name Organization -Value $Organization
                    $object | Add-Member -MemberType NoteProperty -Name username -Value $user.login
                    $object | Add-Member -MemberType NoteProperty -Name Admin-Account -Value $isadmin
                    $object | Add-Member -MemberType NoteProperty -Name Service-Account -Value $isServiceAccount
                    $object | Add-Member -MemberType NoteProperty -Name Local-Account -Value $true
                    
                    $foundAccounts += $object
                }
    
  }
#Endregion

return $foundAccounts