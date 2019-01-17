#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

<# 
 .SYNOPSIS
  Removes a certificate from the trust store.

 .DESCRIPTION
  Removes a certificate from the trust store.

 .PARAMETER Thumbprint
  The SHA1 thumbprint of the certificate to remove

 .EXAMPLE
   # Show usage.
   Remove-HPESvtCertificate

 .EXAMPLE
   # Remove a certificate
   Remove-HPESvtCertificate -Thumbprint
#>


function Remove-HPESvtCertificate {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
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
    $url += '/' + $Thumbprint

    # Issue the DELETE operation and expect a response object in return.
    $skipCertParam = Get-SkipCertificateFlag

    if ($PSCmdlet.ShouldProcess($Thumbprint)) {
        $response = Invoke-RestMethod -Header $header -Uri $url -Method Delete @skipCertParam
    }

    # Print out the response object.
    Write-Output $response
}

Export-ModuleMember -function Remove-HPESvtCertificate
