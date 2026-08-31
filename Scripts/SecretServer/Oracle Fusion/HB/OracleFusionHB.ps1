#requires -Version 7.0

[string]$Username = $args[0]
[string]$Password = $args[1]
[string]$BaseUrl = $args[2]
# --- Logger Setup ---
$logFolder = "C:\Program Files\Thycotic Software Ltd\Distributed Engine\log\Oracle Fusion RPC"
$logFile = Join-Path $logFolder "Heartbeat-$(Get-Date -Format 'yyyyMMdd').log"

function Write-Log {
  param([string]$Message, [string]$Level = "INFO")
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $entry = "[$ts] [$Level] $Message"
  if (-not (Test-Path $logFolder)) { New-Item -ItemType Directory -Path $logFolder -Force | Out-Null }
  Add-Content -Path $logFile -Value $entry
}

Write-Log "================================================================"
Write-Log "Oracle Fusion Heartbeat Started"
Write-Log "================================================================"
Write-Log "Target Username: $Username"
Write-Log "Pod Base URL: $BaseUrl"

try {
  # ===========================================
  # HEARTBEAT: Basic Auth Password Verification
  # ===========================================
  Write-Log "---------- Password Verification Started ----------"

  # --- Build Basic Auth header ---
  Write-Log "Building Basic Auth credentials for target user..."
  $credString = "$Username`:$Password"
  $credBase64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credString))
  $headers = @{
    Authorization = "Basic $credBase64"
    Accept        = "application/json"
  }
  Write-Log "Basic Auth header created"

  # --- Test authentication against SCIM endpoint ---
  $testUrl = "$BaseUrl/hcmRestApi/scim/Users?count=1"
  Write-Log "Test endpoint: $testUrl"
  Write-Log "Sending GET request to verify credentials..."

  try {
    $response = Invoke-RestMethod -Method Get -Uri $testUrl -Headers $headers -ErrorAction Stop
    
    # If we get here, authentication succeeded
    Write-Log "Authentication successful - received valid response"
    Write-Log "Response contains $($response.itemsPerPage) item(s)"
    Write-Log "---------- Password Verification Completed ----------"
    Write-Log "================================================================"
    Write-Log "Heartbeat SUCCESS - Password verified for: $Username"
    Write-Log "================================================================"

    # Return success for Secret Server
    return $true
  }
  catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Log "HTTP Status Code: $statusCode" "ERROR"

    if ($statusCode -eq 401) {
      Write-Log "Authentication FAILED - Invalid password for user: $Username" "ERROR"
      throw "Invalid password for user '$Username'."
    }
    elseif ($statusCode -eq 403) {
      Write-Log "Authentication FAILED - Access forbidden for user: $Username" "ERROR"
      throw "Access forbidden for user '$Username'. User may lack API permissions."
    }
    else {
      Write-Log "Request failed with status: $statusCode" "ERROR"
      Write-Log "Error details: $($_.Exception.Message)" "ERROR"
      throw
    }
  }
}
catch {
  Write-Log "ERROR: $($_.Exception.Message)" "ERROR"
  Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
  Write-Log "================================================================" "ERROR"
  Write-Log "Heartbeat FAILED" "ERROR"
  Write-Log "================================================================" "ERROR"
  throw
}