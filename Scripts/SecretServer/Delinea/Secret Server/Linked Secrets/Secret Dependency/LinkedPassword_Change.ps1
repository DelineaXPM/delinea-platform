# Arguments to use in Dependency changer: $PASSWORD $[1]$USERNAME $[1]$PASSWORD $<Field Name> 
# Advanced arguments Dependency changer: $PASSWORD $[1]$USERNAME $[1]$PASSWORD $<Field Name> [RotatePassword|UpdatePassword] [BulkAction|Legacy]

# Configuration
$DelineaPlatformURL = "https:// <tenant> .delinea.app/"  # URL for delinea platform ex "https://privotter-services.delinea.app/" use $null to authenticate directly to Secret Server
$SecretServerURL = $null # IRL for secret server ex "https://privotter-services.secretservercloud.com/" use $null to retrieve from Delinea Platform
$debug = $false

# Parameters
$newpassword = $args[0]
$apiusername = $args[1]
$apipassword = $args[2]
$linked = $args[3].split(",")
$SecretAction = if ($args[4]) { $args[4] } else { "UpdatePassword" } # Valid Options "RotatePassword", "UpdatePassword"
$UpdateMode = if ($args[5]) { $args[5] } else { "BulkAction" }       # Set to "Legacy" to avoid bulk actions. Needed for older Secret Server versions and some specific use cases. Otherwise use "BulkAction"

# Logging
$logPaths = @("$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log", "c:\inetpub\wwwroot\secretserver\log", "c:\temp", "c:\windows\temp")
$errorfile = $null

foreach ($logPath in $logPaths) {
    if (Test-Path -Path $logPath -PathType Container) {
        $errorfile = Join-Path -Path $logPath -ChildPath "LinkedSecretsDependencyChanger.log"
        break
    }
}

function Write-Debug-Log {
    param([string]$Activity, [hashtable]$Data)
    if (-not $debug -or -not $errorfile) { return }
    
    $output = @((Get-Date).ToString(), $Activity, ($Data | ConvertTo-Json -Compress -Depth 10)) -join "`t"
    $output | Out-File -FilePath $errorfile -Append
}

# Authentication
try {
    if ($null -ne $DelineaPlatformURL) {
        $AuthBody = @{
            client_id = $apiusername
            client_secret = $apipassword
            grant_type = "client_credentials"
            scope = "xpmheadless"
        }
        
        try {
            $response = Invoke-RestMethod -Uri "$DelineaPlatformURL/identity/api/oauth2/token/xpmplatform" `
                -Method Post -Body $AuthBody -ContentType "application/x-www-form-urlencoded"
            $token = $response.access_token
        }
        catch {
            Write-Debug-Log "AuthError" @{ Error = $_.Exception.Message }
            throw "Failed to authenticate to Delinea Platform: $_"
        }
        
        if ($null -eq $SecretServerURL) {
            $vaults = Invoke-RestMethod -Uri "$DelineaPlatformURL/vaultbroker/api/vaults?includeInactive=true&api-version=1.0" `
                -Method Get -Headers @{ Authorization = "Bearer $token" }
            $SecretServerURL = ($vaults.vaults | Where-Object { $_.type -eq "Secretservercloud" }).connection.url
        }
    }
    elseif ($null -ne $SecretServerURL) {
        $AuthBody = @{ username = $apiusername; password = $apipassword; grant_type = "password" }
        $Token = (Invoke-RestMethod -Uri "$SecretServerURL/oauth2/token" -Method Post -Body $AuthBody -ContentType "application/x-www-form-urlencoded").access_token
    
    }
    else {
        throw "Delinea Platform URL and Secret Server URL are both blank."
    }
}
catch { throw $_.Exception.Message }
$token

Write-Debug-Log "Authenticated" @{
    DelineaPlatformURL = $DelineaPlatformURL
    SecretServerURL = $SecretServerURL
    Token = $token.Substring(0, 10) + "..."
    APIUser = $apiusername
    SecretCount = $linked.Count
    SecretAction = $SecretAction
    UpdateMode = $UpdateMode
}

$errorlist = @()

# Bulk operations
if ($UpdateMode -eq "BulkAction") {
    Write-Debug-Log "BulkOperation" @{ Action = $SecretAction; Count = $linked.Count }
    
    $body = @{ data = @{ secretIds = $linked } }
    
    if ($SecretAction -eq "UpdatePassword") {
        $body.data.secretFieldUpdates = @(@{ action = "replace"; slug = "password"; fieldUpdateValue = $newpassword })
        $uri = "$SecretServerURL/api/v1/bulk-secret-operations/update-secret-fields"
    }
    elseif ($SecretAction -eq "RotatePassword") {
        $body.data.nextPassword = $newpassword
        $uri = "$SecretServerURL/api/v1/bulk-secret-operations/change-password-remotely"
    }
    else {
        throw "Invalid SecretAction: $SecretAction"
    }
    
    $operation = Invoke-RestMethod -Uri $uri -Body ($body | ConvertTo-Json -Depth 10) `
        -Method Post -Headers @{ Authorization = "Bearer $token" } -ContentType "application/json"
    
    $starttime = Get-Date
    $running = $true
    $maxWait = $linked.Count * 5
    
    while ($running -and ((Get-Date) - $starttime).TotalSeconds -lt $maxWait) {
        Start-Sleep -Milliseconds 500
        $progress = Invoke-RestMethod -Uri "$SecretServerURL/api/v1/bulk-operations/$($operation.bulkOperationId)/progress" `
            -Method Get -Headers @{ Authorization = "Bearer $token" }
        
        if ($progress.iscomplete) { $running = $false }
        
        Write-Debug-Log "BulkProgress" @{ ElapsedSeconds = [int]((Get-Date) - $starttime).TotalSeconds }
    }
    
    if ($progress.errors) {
        $errorlist = $progress.errors | ForEach-Object { $_.errorMessage }
        Write-Debug-Log "BulkErrors" @{ Errors = $errorlist }
        throw "Bulk operation failed: $($errorlist -join ' | ')"
    }
}
# Legacy (non Bulk) operations
elseif ($UpdateMode -eq "Legacy") {
    Write-Debug-Log "LegacyOperation" @{ Action = $SecretAction; Count = $linked.Count }
    
    foreach ($SecretID in $linked) {
        $uri = "$SecretServerURL/api/v1/secrets/$secretid"
        
        try {
            if ($SecretAction -eq "UpdatePassword") {
                Invoke-RestMethod "$uri/fields/password" -Method PUT `
                    -Headers @{ Authorization = "Bearer $token" } `
                    -Body (@{ value = $newpassword } | ConvertTo-Json -Depth 10) `
                    -ContentType 'application/json' | Out-Null
            }
            elseif ($SecretAction -eq "RotatePassword") {
                Invoke-RestMethod "$uri/change-password" -Method POST `
                    -Headers @{ Authorization = "Bearer $token" } `
                    -Body (@{ newPassword = $newpassword } | ConvertTo-Json -Depth 10) `
                    -ContentType "application/json" | Out-Null
            }
            else {
                throw "Invalid SecretAction: $SecretAction"
            }
            
            Write-Debug-Log "Success" @{ SecretID = $secretid }
        }
        catch {
            $errorlist += $secretid
            Write-Debug-Log "Error" @{ SecretID = $secretid; Details = $_.ErrorDetails }
        }
    }
    
    if ($errorlist.Count -gt 0) {
        throw "Failed to update secret IDs: $($errorlist -join ', ')"
    }
}
else {
    throw "Invalid UpdateMode: $UpdateMode"
}
