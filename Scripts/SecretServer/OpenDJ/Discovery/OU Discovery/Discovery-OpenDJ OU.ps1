<#
    Created by Cagdas Barak - Delinea
    
.SYNOPSIS
    OpenDJ - Created so that the OpenLDAP account can Heartbeat.
.DESCRIPTION
    OpenDJ - Created so that the OpenLDAP account can Heartbeat.
.NOTES
   -
#>

$ldaphost = 'openldap.delinea.test'
$ldapport = '10389'
$dnInput = 'delinea.test'
$useragent = $args[0]
$userpass = $args[1]

# Separating dc components using the dot mark
$dcComponents = $dnInput -split '\.'
$dn = "dc=" + ($dcComponents -join ',dc=')

# Create LDAP connection string
$ldapConnectionString = "LDAP://$($ldaphost):$($ldapport)/$dn"

# Create LDAP connection
$ldapConnection = New-Object DirectoryServices.DirectoryEntry($ldapConnectionString, $useragent, $userpass)

# Initialize an array to store OU information
$FoundOpenDJOrganizationalUnits = @()

# Authentication process
try {
    $ldapConnection.psbase.AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::FastBind
    $ldapConnection.psbase.RefreshCache()

    # If authentication is successful
    if ($ldapConnection.psbase.name -ne $null) {
        
        # Perform an LDAP search to retrieve all Organizational Units
        $searcher = New-Object DirectoryServices.DirectorySearcher($ldapConnection)
        $searcher.Filter = "(objectClass=organizationalUnit)"
        
        $results = $searcher.FindAll()
        
        # Collect and display OU information
        foreach ($result in $results) {
            $ou = $result.GetDirectoryEntry()
            $ouName = $ou.Properties['ou'][0]
            $ouPath = "ou=$ouName,$dn"
            $distinguishedName = $ou.Path
            
            # Create a custom object to store OU information
            $ouObject = New-Object PSObject -Property @{
                OrganizationalUnitName = $ouName
                Path = $ouPath
                DistinguishedName = $distinguishedName
                Domain = $ldaphost
            }

            # Add the OU object to the array
            $FoundOpenDJOrganizationalUnits += $ouObject
        }
    } else {
        Write-Host "Authentication failed: Incorrect user name or password."
    }
} catch {
    Write-Host "Authentication error: $_"
} finally {
    # Close LDAP connection
    $ldapConnection.Close()
}

# Display the collected OU information with the desired order of fields
$FoundOpenDJOrganizationalUnits | Select-Object -Property OrganizationalUnitName, Path, DistinguishedName, Domain