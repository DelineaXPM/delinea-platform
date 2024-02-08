# Expected Argd args=@("Discovery Mode Advanced/Default", "Coveo Tenenant Base URL", "Coveo OrgID",  "API Key","API KeyId","[AdminGroup]=[AdminGroupId]{,[AdditionalGroup]=[AdditionalGroupID]}","[ServiceGroup]=[ServiceGroupId]{,[AdditionalGroup]=[AdditionalGroupID]}"  )

## This block will be used when passing args in from Secret Server

 
    $baseURL           = $args[0]
    $OrgId             = $args[1]
    $apiKey            = $args[2]
    $adminUsers        = $args[3]
    $serviceUsers      = $args[4]

#region define variables
#Define descriptive variables for use in script & set values.

#Script Constants
#[string]$LogFile              = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Coveo-Connector.log"
[string]$LogFile              = "c:\temp\Coveo-Connector.log"
[int32]$LogLevel              = 3
[string]$logApplicationHeader = "Coveo Discovery"

$foundAccounts                = @()
$authHeader                   = @{
    "Authorization" = "Bearer $ApiKey"
    "Accqept" = "application/json"
    "Content-Type" = "application/json"
}
#endregion


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


## Get List of All Groups from Coveo

function IsPrivilege {
    Param ($PrivGroups, $UsersGroups )
    $isPrivUser = $False

    Try {
        #Process Users
        Write-Log -Errorlevel 0 -Message "Matching Discovered Users to Admin/Service Group (Privilege) Membership"  
    
        # get list of all users ...
        if ($PrivGroups.split(',').count -gt 1) {
            foreach ($PrivGroupID in $PrivGroups.split(',')) {
                if ($usersgroups.id.contains($PrivGroupID.split('=')[1])) {
                    $isPrivUser = $true
                    break
                }
            }
        }
        elseif ($PrivGroups.split(',').count -eq 1) {
                if ($usersgroups.id.contains($privgroups.split('=')[1])) {
                    $isPrivUser = $true
                }
            }
    }

    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED:  Matching Discovered Users to Admin/Service Group Membership"
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }
    return $isPrivUser
}

function Get-AllUsers {
    Param ([string]$OrgId)
    $foundAccounts = @()
    $listUsersApi = "/rest/organizations/$($OrgId)/members"
    $uri = $baseURL+$listUsersApi

    Try {
        #Process Users
        Write-Log -Errorlevel 0 -Message "Discovering All Users"  
    
        $userListResponse = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader

        foreach ($user in $userListResponse) {
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name Username -Value $user.providerUsername
            $object | Add-Member -MemberType NoteProperty -Name tenant-url -Value $baseURL

            foreach ($group in $user.groups) {
                # Check for Admin privilege by group membership
                $PrivStatus = isPrivilege -PrivGroup $adminUsers -UsersGroups $group  
                if ($PrivStatus -eq $True) {
                    break
                }
            }
            $object | Add-Member -MemberType NoteProperty -Name IsAdmin -Value $PrivStatus 

            foreach ($group in $user.groups) {
                # Check for Admin privilege by group membership
                $PrivStatus = isPrivilege -PrivGroup $serviceUsers -UsersGroups $group  
                if ($PrivStatus -eq $True) {
                    break
                }
            }
            $object | Add-Member -MemberType NoteProperty -Name IsService -Value $PrivStatus 
            $object | Add-Member -MemberType NoteProperty -Name IsLocal -Value $True 

            $foundAccounts += $object
        }
    }
    catch {
        $Err = $_
        Write-Log -ErrorLevel 0 -Message "FAILED:  Discovering All Users."
        Write-Log -ErrorLevel 2 -Message $Err.Exception
        throw $Err.Exception 
    }

    return $foundAccounts
}
####################################
### Main Body Commands
###


$userList = Get-AllUsers -OrgId "pvgrshyinatrpuywfcqqocusbqm"

#returning to Secret Server
return $userList
