# Script usage
# Discovery of Jira Accounts in specific groups
# parameters to provide in Secret Server:
# $[1]$Username $[1]$Password $[1]$URL $[1]$notes

# Uncomment the line below to enable TLS 1.2 if needed
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region define variables
#Define Argument Variables

$AdminEmail = $args[0]
$APIToken = $args[1]
$Instance = $args[2]
$SearchGroups = $args[3]

#Script Constants
[string]$ApplicationName = "Jira"
[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\$($ApplicationName -Replace("\W","_"))-Connector.log"
[int32]$LogLevel = 3

#endregion

#region Error Handling Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0, 1, 2, 3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory, ValueFromPipeline)]
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel, $ApplicationName, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
        # $Color = @{ 0 = 'Green'; 1 = 'Cyan'; 2 = 'Yellow'; 3 = 'Red'}
        # Write-Host -ForegroundColor $Color[$ErrorLevel] -Object ( $DateTime + $Message)
    }
}


###########################  Log Cleanup  ###########################
if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    Write-Log -Errorlevel 2 -Message "Old logdata has been purged."
}

############################## Modules    ###########################
try {
    Write-Log -Errorlevel 0 -Message "Loading Required PowerShell modules"
    
    Import-Module JiraPS -ErrorAction Stop
}
catch {    
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to load JiraPS PowerShell modules"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}
#endregion Error Handling Functions

#Begin Main Process

try {
    Write-Log -ErrorLevel 0 -Message "Authenticating to $applicationame : $Instance "
    
    # Authenticate
    $JiraCred = New-Object System.Management.Automation.PSCredential ($AdminEmail, (ConvertTo-SecureString $APIToken -AsPlainText -Force))
    Set-JiraConfigServer -Server $instance
    New-JiraSession -Credential $JiraCred
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Failed to connect to instance: $instance"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

Try {
    Write-Log -ErrorLevel 0 -Message "Retrieving users"
    $userlist = Invoke-JiraMethod -URI ($Instance + "/rest/api/3/user/search?query=*") -Method get | Where-Object { $_.accounttype -eq "atlassian" -and $_.active -eq $true } | Select-Object accountid, displayname, emailaddress, AdminGroups
    Write-Log -ErrorLevel 0 -Message "Found $($Userlist.Count) active users"
}
catch {
    $Err = $_
    Write-Log -ErrorLevel 0 -Message "Error in user retrieval"
    Write-Log -ErrorLevel 2 -Message $Err.Exception
    throw $Err.Exception
}

Write-Log -ErrorLevel 0 -Message "Parsing Admin Groups"
foreach ($group in $SearchGroups) {
    Try {
        Write-Log -ErrorLevel 1 -Message "Getting membership of $group"
        $members = Get-JiraGroupMember -Group $group
        Write-Log -ErrorLevel 3 -Message "Found $($members.count) users"
        foreach ($index in (0..($userlist.count - 1))) {
            if ($members.AccountId -contains $userlist[$index].accountid ) { 
                Write-Log -ErrorLevel 3 -Message "Processing user $($index + 1) of $($userlist.Count)"
                $userlist[$index].AdminGroups = ($group, $userlist[$index].AdminGroups -join ",").trim(",")
                Write-Log -ErrorLevel 3 -Message "Added $group to $($userlist[$index].emailaddress) access list"
            }
            Write-Log -ErrorLevel 3 -Message "Finished parsing users in $group"
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "Error parsing group: $group"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception
    }
}
$foundaccounts = $userlist | Where-Object -FilterScript { $null -ne $_.AdminGroups }

Write-Log -ErrorLevel 0 -Message "Successfully found $($foundAccounts.count)  Accounts"    
return $foundAccounts