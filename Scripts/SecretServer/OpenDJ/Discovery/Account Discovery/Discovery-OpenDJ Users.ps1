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

# Initialize an array to store user information
$FoundOpenDJUsers = @()

# Authentication process
try {
    $ldapConnection.psbase.AuthenticationType = [System.DirectoryServices.AuthenticationTypes]::FastBind
    $ldapConnection.psbase.RefreshCache()

    # If authentication is successful
    if ($ldapConnection.psbase.name -ne $null) {
        
        # Perform an LDAP search to retrieve all users
        $searcher = New-Object DirectoryServices.DirectorySearcher($ldapConnection)
        $searcher.Filter = "(objectClass=organizationalPerson)"
        
        $results = $searcher.FindAll()
        
        # Collect and display user information
        foreach ($result in $results) {
            $user = $result.GetDirectoryEntry()
            $uid = $user.Properties['uid'][0]
            $username = "uid=$uid,ou=People,$dn"
            $LDAPHost = $ldaphost
            
            # Create a custom object to store user information
            $userObject = New-Object PSObject -Property @{
                username = "`"uid=$uid,ou=People,$dn`""
                LDAPHost = $LDAPHost
            }

            # Add the user object to the array
            $FoundOpenDJUsers += $userObject
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

# Display the collected user information with 'username' and 'LDAPHost' fields
$FoundOpenDJUsers | Select-Object -Property username, LDAPHost