#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script shows the mechanism for grabbing new certificates when
# moving an OVC using the dsv-update-vcenter command.  The command 
# has been fixed in 3.7.8 and beyond.
#

$ErrorActionPreference = "Stop"
$sourcehms = "10.1.2.3"
$desthms = "10.1.3.4"
$ovcip = "10.1.4.5"

#
# When the certficates are bad on a node, you need to use the "emergency" account
#
$emergencycreds =  Get-Credential -UserName "svtcli" -Message "Enter in svtcli password"
Get-HPESvtAuthToken -HostName $ovcip -credential $emergencycreds -emergency

#
# Grab certificates from both HMSes
#
$sourcecerts = Get-HPESvtRootCertificate -hmsHostname $sourcehms
$destcerts = Get-HPESvtRootCertificate -hmsHostname $desthms

#
# add them all to the trust store - note it is feasible / possible to 
# remove sourcecerts after operation is completed
#
$sourcecerts | ForEach-Object -Process {    
    Add-HPESvtCertificate -Certificate $_
}

$destcerts | ForEach-Object -Process {    
    Add-HPESvtCertificate -Certificate $_
}
