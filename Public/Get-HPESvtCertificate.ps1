#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

<# 
 .SYNOPSIS
  Gets certificates from the trust store.

 .DESCRIPTION
  Gets certificates from the trust store.

 .PARAMETER Thumbprint
  The SHA1 thumbprint of the certificate to retrieve

 .EXAMPLE
   # Show usage.
   Get-HPESvtCertificate

 .EXAMPLE
   # Get a certificate
   Get-HPESvtCertificate -Thumbprint
#>


function Get-HPESvtCertificate {
    [CmdletBinding(DefaultParameterSetName='Default')]

    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$false,ParameterSetName='Thumbprint')]
        [string] $Thumbprint
    )

    # Get OAUTH token
    $svtToken = GetCredXml
    $accessToken = $svtToken.AccessToken
    $ovcHostname = $svtToken.HostName
    
    # Get default headers
    $header = Get-Header $accessToken

    # Get URL for /certificates.
    $url = Get-CertificateUrl $ovcHostname
    if ($Thumbprint) {
      $url += '/' + $Thumbprint
    }

    # Issue the GET operation and expect a response object in return.
    $skipCertParam = Get-SkipCertificateFlag
    $response = Invoke-RestMethod -Header $header -Uri $url -Method Get @skipCertParam

    # Write out the certificates to the pipeline.
    $cert = @()
    if ($Thumbprint) {
      $cert += Get-CertificateFromBase64String $response.certificate
    } else {
      foreach ($certificate in $response.certificates) {
        $cert += Get-CertificateFromBase64String $certificate.certificate
      }
    }
    Write-Output $cert
}

Export-ModuleMember -function Get-HPESvtCertificate
