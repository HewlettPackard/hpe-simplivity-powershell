#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script can be run against an ESXi, SCVMM, or Hyper V host 
#
# Get-HostStatus makes sure the certificate from a TLS endpoint validates
# against the OVC trust store.  Note HyperV and SCVMM should add the default
# winrm HTTPS port (:5986)
#
# Add-PKIForHost takes the certificates from the local windows machine, and places 
# them in the OVC trust store.
#

function Get-HostStatus
{
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $HostName,
        [Parameter(Mandatory=$true)]
        [string] $OvcIp,
        [Parameter(Mandatory=$true)]
        [pscredential] $Credential
    )

    Get-HPESvtAuthToken -HostName $OvcIp -credential $Credential -emergency

    #
    # Grab OVC trust store contents
    #
    $ovctruststorecerts = Get-HPESvtCertificate

    #
    # grab the host certificate
    #
    $hostcert = Get-HPESvtTlsCertificate -HostName $HostName

    $ovcchainresults = Get-CertificateChain -LeafCert $hostcert -ExtraCerts $ovctruststorecerts
    if ($ovcchainresults.Success -eq $false)
    {
        Write-Host "The host certificate will not chain"
        Get-ChainResults -Chain $ovcchainresults.Chain
    }
    else 
    {
        Write-Host "Host certificate validated against OVC trust stores"        
        return "VALIDATED"
    }

    #
    # If the certificate doesn't chain, it may be pinned.
    #
    $ovctruststorecerts | ForEach-Object {
        if ($_.Thumbprint -eq $hostcert.Thumbprint)
        {
            Write-Host "Host certificate is PINNED / present in OVC trust stores."   
            return "PINNED"         
        }
    }   

    return "INVALID"
}

function Add-PKIForHost
{
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $HostName,
        [Parameter(Mandatory=$true)]
        [string] $OvcIp,
        [Parameter(Mandatory=$true)]
        [pscredential] $Credential
    )

    #
    # grab the host certificate
    #
    $hostcert = Get-HPESvtTlsCertificate -HostName $HostName

    #
    # Build a chain against Windows trust stores
    #    
    $ovcchainresults = Get-CertificateChain -LeafCert $hostcert 
    if ($ovcchainresults.Success -eq $false)
    {
        Write-Host "The host certificate will not chain"
        Get-ChainResults -Chain $ovcchainresults.Chain
        return $false
    }
 
    Get-HPESvtAuthToken -HostName $OvcIp -credential $Credential -emergency

    #
    # If the certificate doesn't chain, it may be pinned.
    #
    $ovcchainresults.Chain.ChainElements | ForEach-Object {

        $reply = Read-Host -Prompt "Add $($_Certificate.Thumbprint) : [y/n]"
        if ( $reply -match "[yY]" ) { 
            Add-HPESvtCertificate -Certificate $_.Certificate 
        }
    }   
}


$ErrorActionPreference = "Stop"

#
# .source buildchain.ps1
#
. "$PSScriptRoot\buildchain.ps1"

$hostip = "10.0.0.1"
$ovcip = "10.0.0.2"


#
# When the certficates are bad on a node, you need to use the "emergency" account
#
$emergencycreds =  Get-Credential -UserName "svtcli" -Message "Enter in svtcli password"

Get-HostStatus -HostName $hostip -OvcIp $ovcip -Credential $emergencycreds
