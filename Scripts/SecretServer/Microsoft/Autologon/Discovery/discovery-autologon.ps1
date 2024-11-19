$privUser = $args[0]
$privPassword = ConvertTo-SecureString $args[1] -AsPlainText -Force
$privDomain = $args[2]
$ComputerName = $args[3]
$creds = New-Object System.Management.Automation.PSCredential ($("$privDomain\$privUser"), $privPassword)

$scriptBlock = {
    try {
        $checkRegistry = Get-ItemProperty "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction Stop
        $DefaultDomainName = $checkRegistry.DefaultDomainName
        $DefaultUserName = $checkRegistry.DefaultUserName
    } catch {
        throw "No AutoLogon Dependencies found on $env:COMPUTERNAME"
    }
    $ServiceName = "autologon"
    $Dependency = @()
    $obj = "" | Select-Object Machine, ServiceName, Username, Domain
    $obj.Machine = $env:COMPUTERNAME
    $obj.ServiceName = $ServiceName
    $obj.Username = $DefaultUserName
    $obj.Domain = $DefaultDomainName
    $Dependency += $obj
    return $Dependency
}
Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -Credential $creds
