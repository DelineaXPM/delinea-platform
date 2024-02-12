function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,1,2,3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$logApplicationHeader,
        [Parameter(Mandatory,ValueFromPipeline)]
        [int32]$LogLevel,
        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [bool]$LogFileCheck=$false,
        [Parameter(Mandatory=$false)]
        [string]$LogFile=$null
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
        $MessageString = "{0}`t| {1}`t| {2}`t| {3}" -f $Timestamp, $MessageLevel, $logApplicationHeader, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue

    }
    if($LogFileCheck){
        if($LogFile -eq $null -or $LogFile -eq ""){
            throw "Logging check could not happen"
        }
        if (( Get-Item -Path $LogFile -ErrorAction SilentlyContinue ).Length -gt 25MB) {    
            Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
            Write-Log -Errorlevel 2 -Message "Old logdata has been purged."
        }
    }

}
function CreatePsCredObj {
    param (
    [CmdletBinding()]
    [Parameter(Mandatory)]
    [string]$Password,
    [Parameter(Mandatory)]
    [string]$username
    )
    return New-Object System.Management.Automation.PSCredential ($username, (ConvertTo-SecureString -String $Password -AsPlainText -Force))
}
function CheckModuleExist{
    param(
        [string]$ModuleName
    )
    #plz forgive me for this is really ugly, but its needed for us
    try {
        try{Import-Module $ModuleName -ErrorAction Stop -Scope CurrentUser}catch{Install-Module $ModuleName -ErrorAction Stop -Scope CurrentUser -Force -WarningAction Stop}
    }
    catch {throw "Error trying to install the module, Exception: $($_), Message: $($_.Message)"}
}


function Set-RSASignatureFromPEMString {
    param (
        [Parameter(Mandatory=$true, HelpMessage="RSA String from client in tenant is needed.")]
        [System.String]$RSAKey,
        [Parameter(Mandatory=$true, HelpMessage="PEM or CERT.")]
        [System.String]$Type
    )
    $pemContent = $RSAKey -replace '^-----[^-]+-----', '' -replace '-----[^-]+-----$', ''
    $pemContent = $pemContent -replace '\n', '' -replace '\r', ''
    $decodedBytes = [Convert]::FromBase64String($pemContent)
    # possbily axe
    if ($Type.ToUpper() -eq "CERT"){
        try{
            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList ($decodedBytes, $null)
            return $cert
        }
        catch {throw  New-Object System.Exception "Creation of Signing Key failed. Exception Message: $($_.Exception.Message)."}
    }
    #
    elseif ($Type.ToUpper() -eq "PEM"){
        try {        
            $cngKey = [System.Security.Cryptography.CngKey]::Import($decodedBytes, [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
            return [System.Security.Cryptography.RSACng]::new($cngKey)
        }
        catch {throw  New-Object System.Exception "Creation of Signing Key failed. Exception Message: $($_.Exception.Message)."}
    }
    #Space for other types
    else{
        throw New-Object System.Exception "Not a valid type to set RSA keys for. Thowing up here"
    }
}

# Fix this so that it passes custom standard and non standard claims like the C# project
function Get-JWT {
    param (
        [Parameter(Mandatory=$false, HelpMessage="Kid of app.")]
        [System.String]$Kid=$null,
        [Parameter(Mandatory=$true, HelpMessage="targeted audience of the token.")]
        [System.String]$aud,
        [Parameter(Mandatory=$true, HelpMessage="Subject of the token.")]
        [System.String]$sub,
        [Parameter(Mandatory=$true, HelpMessage="Issuer of the token.")]
        [System.String]$iss,
        [Parameter(Mandatory=$false, HelpMessage="Algorithm; ie: RS256 (most common).")]
        [System.String]$alg="RS256",
        [Parameter(Mandatory=$false, HelpMessage="Algorithm; ie: RS256 (most common).")]
        [System.String]$scope=$null,
        [Parameter(Mandatory=$true, HelpMessage="privatekey text")]
        [System.String]$privkey
    )
    $header = @{
        "alg" = $alg
        "typ" = "JWT"
    }
    if ($null -ne $Kid -and $Kid -ne ""){$header.kid = $kid}
    $payload = @{
        "aud" = $aud
        "iss"=  $iss
        "sub" = $sub
        "iat" = [math]::Round((Get-Date -UFormat %s))
        "exp" = [Math]::Floor((Get-Date).ToUniversalTime().AddHours(1).Subtract((Get-Date "1970-01-01")).TotalSeconds)# Token expires in 1 hour
        "jti" = [Guid]::NewGuid().ToString()
    }
    if ($null -ne $scope -and $scope -ne ""){$payload.scope = $scope}
    $encodedPayload = ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress))).
    Trim()).
    Replace('+', '-').
    Replace('/', '_').
    TrimEnd('=').
    Trim()
    $encodedHeader = ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($header | ConvertTo-Json -Compress))).
    Trim()).
    Replace('+', '-').
    Replace('/', '_').
    TrimEnd('=').
    Trim()
    $encodedToken = "$encodedHeader.$encodedPayload"
    $dataToSign = [System.Text.Encoding]::UTF8.GetBytes($encodedToken)
    try{
        $rsaSignature = $(Set-RSASignatureFromPEMString -RSAKey $privkey -Type "PEM").SignData($dataToSign, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
        $encodedSignature = [Convert]::ToBase64String($rsaSignature)
    }
    catch {throw  New-Object System.Exception "Signing of JWT failed. Exception Message: $($_.Exception.Message)."}
    $encodedSignature = $encodedSignature.Replace('+', '-').Replace('/', '_').TrimEnd('=')
    $jwt = "$encodedHeader.$encodedPayload.$encodedSignature"
    return [System.String]$jwt
}