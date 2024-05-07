# Specify the directory path to the console application executable
$workingDir = "C:\Program Files\Thycotic Software Ltd"
$exePath = $workingDir + "\Delinea.SS.InsightVM.exe"

# Specify the arguments for the console application
$credentialID = $args[0]
$newPassword = $args[1]
$userName = $args[2]
$password = $args[3]
$baseUrl = $args[4]

function Write-Log {
    param (
        [Parameter(Mandatory=$True,ValueFromPipeline =$True)] $logItem
    )
    $LogPath = "C:\Program Files\Thycotic Software Ltd\Distributed Engine\log\Rapid7.txt"

    [string]$TimeStamp = Get-Date 
    "[$TimeStamp]: " + $logitem | Out-File -FilePath $LogPath -Append
}

# Loggin Section for debugging. This will show the passed variables in the log file.

<#Write-Log "computername is $credentialID"
Write-Log "be logon account  is $newPassword"
Write-Log "current password is $userName"
Write-Log "new password is $password"
Write-Log "powershell user is $baseUrl"#>

Set-Location $workingDir
# Run the console application with arguments
Start-Process -FilePath $exePath -ArgumentList "$credentialID", "$newPassword", "$userName", "$password", "$baseUrl" -NoNewWindow -Wait