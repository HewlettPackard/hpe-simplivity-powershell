#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script shows the mechanism for disabling TLS validation.  This 
# only needs to be run one time in a cluster, results will be replicated
#

$ErrorActionPreference = "Stop"
$ovcip = "10.1.3.4"

#
# When the certficates are bad on a node, you need to use the "emergency" account
#
$emergencycreds =  Get-Credential -UserName "svtcli" -Message "Enter in svtcli password"
Get-HPESvtAuthToken -HostName $ovcip -credential $emergencycreds -emergency

#
# Get, and save old certificates "just in case"
#
$certs = Get-HPESvtCertificate
$certs | ForEach-Object -Process {
    #save off old file
    $path = $_.Thumbprint + ".pem";
    $_.GetRawCertDataString() | Out-File -FilePath $path;
}

#
# delete them - this will turn "off" tls validation
#
$certs | ForEach-Object -Process {    
    Remove-HPESvtCertificate -Thumbprint $_.Thumbprint
}

#
# The system should be restored
#
Write-Host "Success"
