#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script can be run against an HMS to validate the configuration in the network.
# In many cases, this script will be run after hitting the Big Red Button, then
# can be used to verify new chain will work before re-enabling it.  
#
# This is typically the result of changing an invalid vCenter certificate.
#

$ErrorActionPreference = "Stop"
$vcenterip = "10.1.2.3"
$ovcip = "10.1.3.4"

$results = $false

#
# When the certficates are bad on a node, you need to use the "emergency" account
#
$emergencycreds =  Get-Credential -UserName "svtcli" -Message "Enter in svtcli password"


Get-HPESvtAuthToken -HostName $ovcip -credential $emergencycreds -emergency

#
# Grab OVC trust store contents
#
$ovctruststorecerts = Get-HPESvtCertificate

#
# grab vmware certs from HMS
#
$vmwarecerts = Get-HPESvtRootCertificate -Hostname $vcenterip

#
# grab the vcenter certificate
#
$vcentertlscert = Get-HPESvtTlsCertificate -HostName $vcenterip

#
# .source buildchain.ps1
#
. "$PSScriptRoot\buildchain.ps1"

Write-Host "####### Vcenter Certificate ######`n" 
Get-CertDetails -Cert $vcentertlscert


Write-Host "`n####### Vcenter Based Certificate Chain ######`n"

$vcenterchainresults = Get-CertificateChain -LeafCert $vcentertlscert -ExtraCerts $vmwarecerts
if ($vcenterchainresults.Success -eq $false)
{
    Write-Host "The vCenter certificate will not chain to the PKI exposed by the vCenter CA"
    Get-ChainResults -Chain $vcenterchainresults.Chain
    Save-CertificateChain -LeafCert $vcentertlscert -ExtraCerts $vmwarecerts -FileName "vcenterchain.p7b"
}
else 
{
    Write-Host "Vcenter certificate validated against vCenter PKI"
}


Write-Host "`n####### OVC based Certificate Chain ######`n"

$ovcchainresults = Get-CertificateChain -LeafCert $vcentertlscert -ExtraCerts $ovctruststorecerts
if ($ovcchainresults.Success -eq $false)
{
    Write-Host "The vCenter certificate will not chain to the PKI exposed by the OVC trust stores"
    Get-ChainResults -Chain $ovcchainresults.Chain
    Save-CertificateChain -LeafCert $vcentertlscert -ExtraCerts $ovctruststorecerts -FileName "ovctrustchain.p7b"
}
else 
{
    Write-Host "Vcenter certificate validated against OVC trust stores"
}
