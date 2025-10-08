$privUser = $args[0]
$privDomain = $args[1]
$privUserpwd = ConvertTo-SecureString -String $args[2] -AsPlainText -Force
$computer = $args[3]
$username = $args[4]
$password = $args[5]
$domain = $args[6]

$DomainUser = "$domain\$privUser"
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $privUserpwd

$Session = New-PSSession -Credential $Cred -ComputerName $computer

$ScriptBlock = {
    $logonUserSignature =
    @"
[DllImport( "advapi32.dll" )]
public static extern bool LogonUser( String lpszUserName,
                                     String lpszDomain,
                                     String lpszPassword,
                                     int dwLogonType,
                                     int dwLogonProvider,
                                     ref IntPtr phToken );
"@
    $closeHandleSignature =
    @"
[DllImport( "kernel32.dll", CharSet = CharSet.Auto )]
public static extern bool CloseHandle( IntPtr handle );
"@
    $revertToSelfSignature =
    @"
   [DllImport("advapi32.dll", SetLastError = true)]
   public static extern bool RevertToSelf();
"@
    $AdvApi32 = Add-Type -MemberDefinition $logonUserSignature -Name "AdvApi32" -Namespace "PsInvoke.NativeMethods" -PassThru
    $Kernel32 = Add-Type -MemberDefinition $closeHandleSignature -Name "Kernel32" -Namespace "PsInvoke.NativeMethods" -PassThru
    $AdvApi32_2 = Add-Type -MemberDefinition $revertToSelfSignature -Name "AdvApi32_2" -Namespace "PsInvoke.NativeMethods" -PassThru
    [Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null
    function IsLocalUserNamePasswordValid() {
        param(
            [String]$UserName,
            [String]$Password,
            [string]$DomainName
        )
        #LogonType  (BATCH = 4, INTERACTIVE = 2, NETWORK = 3, NETWORK_CLEARTEXT = 8, NEW_CREDENTIALS = 9, SERVICE = 5)
        #LogonProviderID (DEFAULT = 0, WINNT40 = 2, WINNT50 = 3)

        $Logon32ProviderDefault = 0
        $Logon32LogonType = 2
        $tokenHandle = [IntPtr]::Zero
        $success = $false
        $DomainName = $null
        #Attempt a logon using this credential
        $success = $AdvApi32::LogonUser($UserName, $DomainName, $Password, $Logon32LogonType, $Logon32ProviderDefault, [Ref] $tokenHandle)
        if (!$success ) {
            $retVal = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
            return Write-Error -Message "Wrong user or password" -Category AuthenticationError
        } else {
            $Kernel32::CloseHandle( $tokenHandle ) | Out-Null
            return $True
        }
    }
    IsLocalUserNamePasswordValid -UserName $using:username -Password $using:password -Domain $using:domain
}
Invoke-Command -Session $Session -Command $ScriptBlock
