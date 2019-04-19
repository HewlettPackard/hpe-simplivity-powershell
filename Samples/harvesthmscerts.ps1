#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script shows the mechanism for harvesting VCenter certificates
# and adding them to the trust store.  
#
# This is typically the result of changing an invalid vCenter certificate.
#

$ErrorActionPreference = "Stop"
$vcenterip = "10.1.2.3"
$ovcip = "10.1.3.4"

#
# When the certficates are bad on a node, you need to use the "emergency" account
#
$emergencycreds =  Get-Credential -UserName "svtcli" -Message "Enter in svtcli password"
Get-HPESvtAuthToken -HostName $ovcip -credential $emergencycreds -emergency

#
# grab vmware certs from HMS
#
$vmwarecerts = Get-HPESvtRootCertificate -Hostname $vcenterip

#
# plumb them into trust store
#
$vmwarecerts | ForEach-Object -Process {    
    Add-HPESvtCertificate -Certificate $_
}

#
# The system should be restored
#
Write-Host "Success"
