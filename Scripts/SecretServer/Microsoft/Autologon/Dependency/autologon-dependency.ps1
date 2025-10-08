# Expected arguments: $[1]$USERNAME $[1]$DOMAIN $[1]$PASSWORD $MACHINE $PASSWORD
$privUserName = $args[0]
$prefix = $args[1] #this can be a domain or machine name
$privUserName = "$prefix\$privUserName"
$privPassword = ConvertTo-SecureString -AsPlainText $args[2] -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $privUserName, $privPassword

$RestartAfterUpdate = $true     #Should we restart the target computer after updating
$RestartPreDelay = 3            #Durantion of pause before restarting target (In Seconds)

Invoke-Command -ComputerName $args[3] -Credential $creds -ArgumentList $args[4] {
    param ($Password)
    $Password = ConvertTo-SecureString $Password -AsPlainText -Force
    #region C# Code to P-invoke LSA LsaStorePrivateData function.
    Add-Type @"
        using System;
        using System.Collections.Generic;
        using System.Text;
        using System.Runtime.InteropServices;

        namespace ComputerSystem
        {
            public class LSAutil
            {
                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_UNICODE_STRING
                {
                    public UInt16 Length;
                    public UInt16 MaximumLength;
                    public IntPtr Buffer;
                }

                [StructLayout(LayoutKind.Sequential)]
                private struct LSA_OBJECT_ATTRIBUTES
                {
                    public int Length;
                    public IntPtr RootDirectory;
                    public LSA_UNICODE_STRING ObjectName;
                    public uint Attributes;
                    public IntPtr SecurityDescriptor;
                    public IntPtr SecurityQualityOfService;
                }

                private enum LSA_AccessPolicy : long
                {
                    POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
                    POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
                    POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
                    POLICY_TRUST_ADMIN = 0x00000008L,
                    POLICY_CREATE_ACCOUNT = 0x00000010L,
                    POLICY_CREATE_SECRET = 0x00000020L,
                    POLICY_CREATE_PRIVILEGE = 0x00000040L,
                    POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
                    POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
                    POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
                    POLICY_SERVER_ADMIN = 0x00000400L,
                    POLICY_LOOKUP_NAMES = 0x00000800L,
                    POLICY_NOTIFICATION = 0x00001000L
                }

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaRetrievePrivateData(
                            IntPtr PolicyHandle,
                            ref LSA_UNICODE_STRING KeyName,
                            out IntPtr PrivateData
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaStorePrivateData(
                        IntPtr policyHandle,
                        ref LSA_UNICODE_STRING KeyName,
                        ref LSA_UNICODE_STRING PrivateData
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaOpenPolicy(
                    ref LSA_UNICODE_STRING SystemName,
                    ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
                    uint DesiredAccess,
                    out IntPtr PolicyHandle
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaNtStatusToWinError(
                    uint status
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaClose(
                    IntPtr policyHandle
                );

                [DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
                private static extern uint LsaFreeMemory(
                    IntPtr buffer
                );

                private LSA_OBJECT_ATTRIBUTES objectAttributes;
                private LSA_UNICODE_STRING localsystem;
                private LSA_UNICODE_STRING secretName;

                public LSAutil(string key)
                {
                    if (key.Length == 0)
                    {
                        throw new Exception("Key lenght zero");
                    }

                    objectAttributes = new LSA_OBJECT_ATTRIBUTES();
                    objectAttributes.Length = 0;
                    objectAttributes.RootDirectory = IntPtr.Zero;
                    objectAttributes.Attributes = 0;
                    objectAttributes.SecurityDescriptor = IntPtr.Zero;
                    objectAttributes.SecurityQualityOfService = IntPtr.Zero;

                    localsystem = new LSA_UNICODE_STRING();
                    localsystem.Buffer = IntPtr.Zero;
                    localsystem.Length = 0;
                    localsystem.MaximumLength = 0;

                    secretName = new LSA_UNICODE_STRING();
                    secretName.Buffer = Marshal.StringToHGlobalUni(key);
                    secretName.Length = (UInt16)(key.Length * UnicodeEncoding.CharSize);
                    secretName.MaximumLength = (UInt16)((key.Length + 1) * UnicodeEncoding.CharSize);
                }

                private IntPtr GetLsaPolicy(LSA_AccessPolicy access)
                {
                    IntPtr LsaPolicyHandle;

                    uint ntsResult = LsaOpenPolicy(ref this.localsystem, ref this.objectAttributes, (uint)access, out LsaPolicyHandle);

                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaOpenPolicy failed: " + winErrorCode);
                    }

                    return LsaPolicyHandle;
                }

                private static void ReleaseLsaPolicy(IntPtr LsaPolicyHandle)
                {
                    uint ntsResult = LsaClose(LsaPolicyHandle);
                    uint winErrorCode = LsaNtStatusToWinError(ntsResult);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("LsaClose failed: " + winErrorCode);
                    }
                }

                public void SetSecret(string value)
                {
                    LSA_UNICODE_STRING lusSecretData = new LSA_UNICODE_STRING();

                    if (value.Length > 0)
                    {
                        //Create data and key
                        lusSecretData.Buffer = Marshal.StringToHGlobalUni(value);
                        lusSecretData.Length = (UInt16)(value.Length * UnicodeEncoding.CharSize);
                        lusSecretData.MaximumLength = (UInt16)((value.Length + 1) * UnicodeEncoding.CharSize);
                    }
                    else
                    {
                        //Delete data and key
                        lusSecretData.Buffer = IntPtr.Zero;
                        lusSecretData.Length = 0;
                        lusSecretData.MaximumLength = 0;
                    }

                    IntPtr LsaPolicyHandle = GetLsaPolicy(LSA_AccessPolicy.POLICY_CREATE_SECRET);
                    uint result = LsaStorePrivateData(LsaPolicyHandle, ref secretName, ref lusSecretData);
                    ReleaseLsaPolicy(LsaPolicyHandle);

                    uint winErrorCode = LsaNtStatusToWinError(result);
                    if (winErrorCode != 0)
                    {
                        throw new Exception("StorePrivateData failed: " + winErrorCode);
                    }
                }
            }
        }
"@
    #endregion
    try {
        $WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $insecurePass = Get-ItemProperty -Path $WinlogonPath -Name "DefaultPassword" -ErrorAction SilentlyContinue
        #  if(!$insecurePass){
        #      New-ItemProperty -Path $WinlogonPath -Name "DefaultPassword" -PropertyType "string"
        #  }
        # Per testing on Windows 2016, if the DefaultPassword Key exists, Autologin will not leverage the LSA Encrypted Password for authentication
        if ($insecurePass.DefaultPassword.Length -ne 0) {
            Remove-ItemProperty -Path $WinlogonPath -Name "DefaultPassword" -Force
        }
        $decryptedPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        # Store the password securely.
        $lsaUtil = New-Object ComputerSystem.LSAutil -ArgumentList "DefaultPassword"
        $lsaUtil.SetSecret($decryptedPass)
    } catch {
        throw 'Failed to set auto logon password. The error was: "{0}".' -f $_
    }

}

if ($RestartAfterUpdate){
    Start-Sleep -Seconds $RestartPreDelay
    try {
        Invoke-Command -ComputerName $args[3] -Credential $creds -ScriptBlock { Restart-Computer -Force }
    } catch {
        throw 'Failed to restart target maachine. The error was: "{0}".' -f $_
    }

}
