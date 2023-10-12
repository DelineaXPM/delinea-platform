<#
    Created by Cagdas Barak - Delinea
    
.SYNOPSIS
    OpenDJ - Created so that the OpenLDAP account can Heartbeat.
.DESCRIPTION
    OpenDJ - Created so that the OpenLDAP account can Heartbeat.
.NOTES
   -
#>

$ldaphost = $args[0]
$ldapport = $args[1]
$dnInput = $args[2]
$useragent = $args[3]
$userpass = $args[4]

# Separating dc components using the dot mark
$dcComponents = $dnInput -split '\.'
$dn = "dc=" + ($dcComponents -join ',dc=')

# Create LDAP connection string
$ldapConnectionString = "LDAP://$($ldaphost):$($ldapport)/$dn"

# Create LDAP connection
$ldapConnection = New-Object DirectoryServices.DirectoryEntry($ldapConnectionString, $useragent, $userpass)

# Authentication process
try {
    $ldapConnection.psbase.AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::FastBind
    $ldapConnection.psbase.RefreshCache()

    # If authentication is successful
    if ($ldapConnection.psbase.name -ne $null) {
        Write-Host "Authentication successful: $($ldapConnection.psbase.name)"
    } else {
        Write-Host "Authentication failed: Incorrect user name or password."
    }
} catch {
    Write-Host "Authentication error: $_"
} finally {
    # Close LDAP connection
    $ldapConnection.Close()
}