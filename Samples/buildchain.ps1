#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#
# This script builds a certificate chain, has cert viewing functions 
#

function Get-CertDetails
{
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Cert
    )
    
    Write-Host "SHA1 Thumbprint:" $Cert.Thumbprint
    Write-Host "Subject RDN:" $Cert.SubjectName.Name
    $skiExt = $cert.Extensions | Where-Object {$_.Oid.FriendlyName -eq "Subject Key Identifier"}
    Write-Host "Subject KeyID="$skiExt.Format(1)
    Write-Host "Issued By:" $Cert.IssuerName.Name    
    $akiExt = $cert.Extensions | Where-Object {$_.Oid.FriendlyName -eq "Authority Key Identifier"}
    Write-Host "Authority "$akiExt.Format(1)

    Write-Host "Subject Alternative Names: `n"
    $sanExt = $cert.Extensions | Where-Object {$_.Oid.FriendlyName -eq "subject alternative name"}
    if ($null -ne $sanExt)
    {
        $sans = $sanExt.Format(1)
        Write-Host $sans
        $ipthere = Select-String -Pattern "IP Address" -InputObject $sans
        if ($null -eq $ipthere)
        {
            Write-Host "WARNING - NO IP Address detected in SANs - may cause failures"
        }

        $dnsthere = Select-String -Pattern "DNS Name" -InputObject $sans
        if ($null -eq $dnsthere)
        {
            Write-Host "WARNING - NO DNS Name detected in SANs - may cause failures"
        }
    }
    else 
    {
        Write-Host "WARNING - No SANs in certificate - may cause failures."        
    }
}

function Get-ChainResults
{
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Chain] $Chain
    )

    Write-Host("Certificates ")
    $Chain.ChainElements | ForEach-Object {$_.Certificate}

    Write-Host("ChainStatus")
    $Chain.ChainStatus | ForEach-Object {
        $_.Status
        $_.StatusInformation
    }    
}

function Get-CertificateChain
{   
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $LeafCert,
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $ExtraCerts
    )

    $chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain

    if ($null -ne $ExtraCerts)
    {        
        $ExtraCerts | ForEach-Object -Process {
            #save off old file
            $chain.ChainPolicy.ExtraStore.Add($_)
        }       
    }

    $chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::NoCheck

    # Build the certificate chain from the file certificate
    $chainsCorrectly = $chain.Build($LeafCert)
    
    if ($chainsCorrectly -ne $true) {
        #walk all errors, some we are ok with
        $chainsCorrectly = $true
        $chain.ChainStatus | ForEach-Object {

            if (($_.Status -ne [System.Security.Cryptography.X509Certificates.X509ChainStatusFlags]::UntrustedRoot) -and
                ($_.Status -ne [System.Security.Cryptography.X509Certificates.X509ChainStatusFlags]::NoError))
                {
                    $chainsCorrectly = $false
                }    
        }
    }
  
    $ret = [PSCustomObject]@{
         Success = $chainsCorrectly;
         Chain = $chain
    }

    return $ret
}
function Get-IsPowerShellCore {
    $PSVersionTable.PSEdition -and $PsVersionTable.PSEdition -eq 'Core'
}
function Save-CertificateChain
{   
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $FileName,
        [Parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $LeafCert,
        
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $ExtraCerts
    )

      # Core is missing an easy export routine - tbd
    if (Get-IsPowerShellCore) {
        return;
    }

    $finalPath = [Environment]::GetFolderPath("MyDocuments") + "\" + $FileName
    
    
    [System.Security.Cryptography.X509Certificates.X509Certificate2[]] $allCerts = $ExtraCerts
    $allCerts += $LeafCert

    $allCerts | Export-Certificate -FilePath $finalPath -Type P7B
    
    Write-Output "Chain saved to " $FinalPath
}
