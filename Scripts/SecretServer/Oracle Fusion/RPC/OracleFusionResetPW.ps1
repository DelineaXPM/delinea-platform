#requires -Version 7.0

[string]$Username = $args[0]
[string]$Password = $args[1]
[string]$BaseUrl = $args[2]
[string]$PrivateKeyPem = $args[3]
[string]$CertPem = $args[4]
[string]$Issuer = $args[5]
[string]$FusionUser = $args[6]
[int]$TtlSeconds = 300
[bool]$IncludeX5tS256 = $false

# --- Logger Setup ---
$logFolder = "C:\Program Files\Thycotic Software Ltd\Distributed Engine\log\Oracle Fusion RPC"
$logFile = Join-Path $logFolder "PasswordChanger-$(Get-Date -Format 'yyyyMMdd').log"

function Write-Log {
  param([string]$Message, [string]$Level = "INFO")
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $entry = "[$ts] [$Level] $Message"
  if (-not (Test-Path $logFolder)) { New-Item -ItemType Directory -Path $logFolder -Force | Out-Null }
  Add-Content -Path $logFile -Value $entry
}

# --- Helper Functions ---
function Convert-ToBase64Url([byte[]]$Bytes) {
  [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
}
function Convert-StringToBase64Url([string]$Text) {
  Convert-ToBase64Url ([Text.Encoding]::UTF8.GetBytes($Text))
}
function Get-UnixTimeSeconds { [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
function UrlEncode([string]$s) { [System.Uri]::EscapeDataString($s) }

Write-Log "================================================================"
Write-Log "Oracle Fusion Password Changer Started"
Write-Log "================================================================"
Write-Log "Target Username: $Username"
Write-Log "Fusion User (Impersonation): $FusionUser"
Write-Log "Issuer: $Issuer"
Write-Log "Pod Base URL: $BaseUrl"
Write-Log "Key: $PrivateKeyPem"
Write-Log "Cert: $CertPem"

try {
  # ===========================================
  # SECTION 1: JWT GENERATION
  # ===========================================
  Write-Log "---------- JWT Generation Started ----------"

  # --- Extract DER bytes from PEM certificate ---
  Write-Log "Extracting DER bytes from certificate PEM..."
  $certBase64 = $CertPem -replace '-----BEGIN CERTIFICATE-----' -replace '-----END CERTIFICATE-----' -replace '\s'
  $certDerBytes = [Convert]::FromBase64String($certBase64)
  Write-Log "Certificate DER bytes extracted. Length: $($certDerBytes.Length) bytes"

  # --- Calculate thumbprints ---
  Write-Log "Calculating certificate thumbprints..."
  $sha1 = [System.Security.Cryptography.SHA1]::Create()
  $x5t = Convert-ToBase64Url ($sha1.ComputeHash($certDerBytes))
  Write-Log "x5t (SHA1): $x5t"

  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  $x5tS256 = Convert-ToBase64Url ($sha256.ComputeHash($certDerBytes))
  Write-Log "x5t#S256 (SHA256): $x5tS256"

  # --- Build JWT header/payload ---
  Write-Log "Building JWT header and payload..."
  $header = [ordered]@{ alg="RS256"; typ="JWT"; x5t=$x5t }
  if ($IncludeX5tS256) { $header['x5t#S256'] = $x5tS256 }
  $headerJson = $header | ConvertTo-Json -Compress
  Write-Log "Header: $headerJson"

  $iat = Get-UnixTimeSeconds
  $exp = $iat + $TtlSeconds
  $payload = [ordered]@{ iss=$Issuer; prn=$FusionUser; sub=$FusionUser; iat=$iat; exp=$exp }
  $payloadJson = $payload | ConvertTo-Json -Compress
  Write-Log "Payload: $payloadJson"
  Write-Log "Token iat: $iat | exp: $exp (TTL: $TtlSeconds seconds)"

  $signingInput = "$(Convert-StringToBase64Url $headerJson).$(Convert-StringToBase64Url $payloadJson)"

  # --- Load RSA private key ---
  Write-Log "Loading RSA private key from PEM..."
  $rsa = [System.Security.Cryptography.RSA]::Create()
  $rsa.ImportFromPem($PrivateKeyPem)
  Write-Log "RSA key loaded. Key size: $($rsa.KeySize) bits"

  # --- Sign JWT ---
  Write-Log "Signing JWT with RS256..."
  $bytesToSign = [Text.Encoding]::UTF8.GetBytes($signingInput)
  $sig = $rsa.SignData(
    $bytesToSign,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
  )
  $jwt = "$signingInput.$(Convert-ToBase64Url $sig)"

  if ([string]::IsNullOrEmpty($jwt)) {
    Write-Log "JWT generation failed - token is null or empty" "ERROR"
    throw "JWT generation failed"
  }
  Write-Log "JWT generated successfully. Length: $($jwt.Length) characters"
  Write-Log "---------- JWT Generation Completed ----------"

  # ===========================================
  # SECTION 2: SCIM USER LOOKUP
  # ===========================================
  Write-Log "---------- SCIM User Lookup Started ----------"

  $commonHeaders = @{
    Authorization = "Bearer $jwt"
    Accept        = "application/json"
  }

  # --- Find user by SCIM filter ---
  $filter = 'userName eq "' + $Username.Replace('"','\"') + '"'
  $usersUrl = "$BaseUrl/hcmRestApi/scim/Users?filter=$(UrlEncode $filter)&startIndex=1&count=2"
  Write-Log "SCIM Users endpoint: $usersUrl"
  Write-Log "Filter: $filter"

  Write-Log "Sending GET request to find user..."
  $usersResp = Invoke-RestMethod -Method Get -Uri $usersUrl -Headers $commonHeaders

  $user = $usersResp.Resources | Select-Object -First 1
  if (-not $user) {
    Write-Log "No SCIM user found for userName='$Username'" "ERROR"
    throw "No SCIM user found for userName='$Username'."
  }

  $userId = $user.id
  Write-Log "User found! SCIM ID: $userId | userName: $($user.userName)"
  Write-Log "---------- SCIM User Lookup Completed ----------"

  # ===========================================
  # SECTION 3: PASSWORD CHANGE
  # ===========================================
  Write-Log "---------- Password Change Started ----------"

  $patchUrl = "$BaseUrl/hcmRestApi/scim/Users/$userId"
  Write-Log "PATCH endpoint: $patchUrl"

  $patchHeaders = @{
    Authorization  = "Bearer $jwt"
    Accept         = "application/json"
    "Content-Type" = "application/json"
  }

  $patchBodyObj = @{
    schemas  = @("urn:scim:schemas:core:2.0:User")
    password = $Password
  }
  $patchBody = $patchBodyObj | ConvertTo-Json -Depth 10
  Write-Log "PATCH body prepared (password redacted for security)"

  Write-Log "Sending PATCH request to change password..."
  $resp = Invoke-RestMethod -Method Patch -Uri $patchUrl -Headers $patchHeaders -Body $patchBody -SkipHttpErrorCheck

  $respJson = $resp | ConvertTo-Json -Depth 10
  Write-Log "PATCH response received"
  Write-Log "Response: $respJson"

  # --- Validate response ---
  if ($resp.id -eq $userId) {
    Write-Log "Password change successful for user: $Username (ID: $userId)"
  } else {
    Write-Log "Password change may have failed. Review response above." "WARN"
  }

  Write-Log "---------- Password Change Completed ----------"
  Write-Log "================================================================"
  Write-Log "Oracle Fusion Password Changer Finished Successfully"
  Write-Log "================================================================"

}
catch {
  Write-Log "ERROR: $($_.Exception.Message)" "ERROR"
  Write-Log "Stack Trace: $($_.ScriptStackTrace)" "ERROR"
  Write-Log "================================================================" "ERROR"
  Write-Log "Oracle Fusion Password Changer Failed" "ERROR"
  Write-Log "================================================================" "ERROR"
  throw
}