$container = $args[0]
$domain = $args[1]
$username = $args[2]
$password = $args[3]

#IPRangeLookup
# parse out the range from the container args
$ranges = $container.Substring($container.IndexOf('=') + 1,($container.Length - $container.IndexOf('='))-1)

# cidr format, specificOU, 

$distinguisheddomain = "DC=" + ($domain.Split('.') -join ",DC=");
$targetMachines = $null

write-debug "Starting..."

function Is-LocalIP {
   param(
       [string]$targetIp,
       [string[]]$localIps
   )

   Foreach ($ip in $localIps) {  
            
            if ($ip -eq $targetIp) { 
                    "Yes it's here: " 
                    return $true
                }
        }  
}

function Is-ValidIP {
  param(
       [string]$containerName
   )

    return [bool]($containerName -as [ipaddress])
}

function Is-ValidRange {
  param(
       [string]$containerName
   )
   if ($containerName -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}[-].[0-9]{1,3}$") 
   {
        return $true;
   }
}

function Get-IpAddressesFromRange {
    param(
       [string]$containerName
    )
    try {
        $ipAddresses = @() 
        $ipAddresses = @() 
        $parts = $containerName.Split("-");
        $baseIpParts = $parts[0].Split(".")
        $baseIp = "$($baseIpParts[0]).$($baseIpParts[1]).$($baseIpParts[2])"
        $start = [convert]::ToInt32($baseIpParts[3], 10)
        $end = [convert]::ToInt32($parts[1], 10)
        
 
        for ($i = $start; $i -le $end; $i++) 
        { 
           $ipAddresses += "$baseIp.$i"
        }
        return $ipAddresses

    }
    catch {
        write-debug ("Error occured generating IP Addresses: `n{0}" -f $_.Exception.ToString())
    }
}

function IsIpAddressInOtherRanges {
param(
    [string] $ipAddress
    )

    foreach ($range in $ranges) {
        $parts = $range.Split("-")
        $start = $parts[0]
        $baseIpParts = $parts[0].Split(".")
        $end =  "$($baseIpParts[0]).$($baseIpParts[1]).$($baseIpParts[2]).$($parts[1])"
        if (IsIpAddressInRange $ipAddress $start $end) {
            return $true;
        }
    }
    return $false;
}

function IsIpAddressInRange {
param(
        [string] $ipAddress,
        [string] $fromAddress,
        [string] $toAddress
    )

    $ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
    [array]::Reverse($ip)
    $ip = [system.BitConverter]::ToUInt32($ip, 0)

    $from = [system.net.ipaddress]::Parse($fromAddress).GetAddressBytes()
    [array]::Reverse($from)
    $from = [system.BitConverter]::ToUInt32($from, 0)

    $to = [system.net.ipaddress]::Parse($toAddress).GetAddressBytes()
    [array]::Reverse($to)
    $to = [system.BitConverter]::ToUInt32($to, 0)

    $from -le $ip -and $ip -le $to
}

$Spassword = ConvertTo-SecureString "$password" -AsPlainText -Force #Secure PW
$cred = New-Object System.Management.Automation.PSCredential ("$username", $Spassword) #Set credentials for PSCredential logon

$isContainerIpAddress = $false
$targetMachines = @()
$containerIp = $container.Replace("OU=","")
write-debug $containerIp
if (Is-ValidIP -containerName $containerIp) {
    write-debug "Valid IP"
    $targetMachines += $containerIp
    $isContainerIpAddress = $true
}

if (Is-ValidRange -containerName $containerIp) {
    write-debug "Valid Range"
    $targetMachines = Get-IpAddressesFromRange -containerName $containerIp
    $isContainerIpAddress = $true

}

if (!$isContainerIpAddress) {   
    
    write-debug "container check"
    if ($distinguisheddomain.tolower() -eq $container.tolower())
    {
        $searchbase = $distinguisheddomain
    }
    else
    {
        $searchbase = $container+","+$distinguisheddomain
    }
    $filter = 'Name -like "*"'
    write-debug "finding targets"
    $targetMachines = Get-ADComputer -Credential $cred -Filter $filter -Server $domain -SearchBase $searchbase -properties *
    write-debug "found targets"
}

write-debug "Getting local IP's.."
$ipaddresses = Get-WMIObject win32_NetworkAdapterConfiguration
$addresses=@()
Foreach ($i in $ipaddresses) { 
    if ($i.IPAddress) { 
        $ipsplit = $i.IPAddress.Split()  
        Foreach ($ip in $ipsplit) {  
            $addresses += $ip
        }      
    }
}
$FoundComputers = @()

write-debug "Scanning targets..."
foreach ($target in $targetMachines)
{
    write-debug "Scanning target.."
    write-debug $target
    $comp = $null
    $adComputer = $null
    if ($isContainerIpAddress) {  
            
        write-debug "Testing IP's"
        if ((test-connection $target –count 1 -quiet)) {
                write-debug "found target $target"
                try
                {
                $isDomainController = $false
                if($addresses.Contains($target)) {
                    $osInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $target
                    $comp = Get-WmiObject Win32_ComputerSystem -ComputerName $target
                }
                else {
                    $machineCred = New-Object System.Management.Automation.PSCredential ("$target\$username", $Spassword)
                    $osInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $target -Credential $machineCred -ErrorAction SilentlyContinue
                    $comp = Get-WmiObject Win32_ComputerSystem -ComputerName $target -Credential $Machinecred -ErrorAction SilentlyContinue
                    $GUID = Get-WmiObject Win32_ComputerSystemProduct -ComputerName $target -Credential $Machinecred -ErrorAction SilentlyContinue
                    $isDomainController = (($comp).domainrole -in 4,5)
                }
                if (($isDomainController))
               {
                    $adComputer = Get-ADComputer -Filter "Name -eq '$($comp.Name)'" -Server $domain  -properties * -Credential $cred
                }

                }
                catch
                {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName 
                    write-debug "$target  $FailedItem $ErrorMessage"
                }
        }
        else {
            
            continue
        }
    }
    else {
        $targetIP = Test-Connection $target.Name -Count 1 -ErrorAction SilentlyContinue | select -ExpandProperty ipv4address
        if ($targetIP -and !(IsIpAddressInOtherRanges -ipAddress $targetIP)) 
        {
            write-debug "found target"
            $adComputer = $target
        }
    }
    if ($adComputer -ne $null)
    {  
            write-debug "Ad Computer: $adComputer" 
            $object = New-Object –TypeName PSObject;
            $object | Add-Member -MemberType NoteProperty -Name Machine -Value $adComputer.Name;
            #$object | Add-Member -MemberType NoteProperty -Name DNSHostName -Value $adComputer.DNSHostName;
            #$object | Add-Member -MemberType NoteProperty -Name ADGUID -Value $adComputer.ObjectGuid
            #$object | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $adComputer.OperatingSystem;
            #if ($isContainerIpAddress) {
            #    $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value "CN=$($adComputer.Name),$container"
            #}
            #else {
            #    $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $adComputer.DistinguishedName.Replace(",$distinguisheddomain", '');
            #}
            $FoundComputers += $object
            $object = $null
    }
    else{
            $object = New-Object –TypeName PSObject;
            $object | Add-Member -MemberType NoteProperty -Name Machine -Value $comp.Name;
            #$object | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $osInfo.Caption;
            #$object | Add-Member -MemberType NoteProperty -Name DNSHostName -Value $comp.DNSHostName;
            #$object | Add-Member -MemberType NoteProperty -Name ADGUID -Value $GUID.UUID;


# Modified to append IP ADDRESS, not IP address RANGE
#            if ($isContainerIpAddress) {
#               $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value "CN=$($comp.Name),$container"
#                $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value "CN=$($comp.Name),$target"
#            }
#            else {
#                $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $comp.DistinguishedName.Replace(",$distinguisheddomain", '');
#            }

# Modified to return machine details only if it is not part of a domain
            if ($comp.PartOfDomain) {
                write-debug "Machine is part of a domain"
            }
            else {
                write-debug "Machine is NOT part of a domain"
                $FoundComputers += $object
            }

            $object = $null
    
    }
}

write-debug "Finished.."

$SanitizedFoundComputers = @()

foreach ($computer in $FoundComputers) {
   if (($computer.Machine -ne $null)) {
       $SanitizedFoundComputers += $computer
   }
}
return $SanitizedFoundComputers
