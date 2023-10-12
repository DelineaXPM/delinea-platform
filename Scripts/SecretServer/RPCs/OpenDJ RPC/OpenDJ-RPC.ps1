<#
    Created by Cagdas Barak - Delinea
    
.SYNOPSIS
    OpenDJ - Created so that the OpenLDAP account can RPC.
.DESCRIPTION
    OpenDJ - Created so that the OpenLDAP account can RPC.
.NOTES
   -
#>

$hostname = $args[0]
$port = $args[1]
$adminDN = $args[2]
$bindPassword = $args[3]
$userDN = $args[4]
$newPassword = $args[5]

$ldappasswordmodifyPath = "C:\opendj\bat\ldappasswordmodify.bat"

# Run the ldappasswordmodify.bat command
$authzid = "dn:$userDN"
$arguments = @(
    "-h", "`"$hostname`"",
    "-p", "`"$port`"",
    "-D", "`"$adminDN`"",
    "-w", "`"$bindPassword`"",
    "-a", "`"$authzid`"",
    "-n", "`"$newPassword`""
)

# Runs ldappasswordmodify.bat with parameters.
Start-Process -FilePath $ldappasswordmodifyPath -ArgumentList $arguments -Wait