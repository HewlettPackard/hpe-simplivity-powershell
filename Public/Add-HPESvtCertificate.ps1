#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

<# 
 .SYNOPSIS
  Adds a certificate to the HPE SimpliVity trust store.

 .DESCRIPTION
  Adds a certificate to the HPE SimpliVity trust store.

 .PARAMETER Certificate
  Specifies the X509Certificate2 object.
  
 .PARAMETER Path
  Specifies the path to a certificate file.

 .EXAMPLE
   # Add a certificate
   Add-HPESvtCertificate -Path test.pem
#>


function Add-HPESvtCertificate {
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory,
            ParameterSetName = 'Certificate',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [parameter(
            Mandatory,
            ParameterSetName  = 'Path',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Path    
    )

    Process {
        # Get certificate either from the certificate object or a file
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Certificate'   { $cert = $Certificate }
                'Path'          { $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($Path) }
            }
        } catch {
            Write-Error "Unable to open certificate file"
            Break
        }

        Write-Verbose "Adding the following certificate:`n $cert"
        $certData = [System.Convert]::ToBase64String($cert.RawData)
        $certData = $BEGIN_CERTIFICATE + "`n$certData`n" + $END_CERTIFICATE

        # Get OAUTH token
        $svtToken = GetCredXml
        $accessToken = $svtToken.AccessToken
        $ovcHostname = $svtToken.HostName

        # Get default headers
        $header = Get-Header $accessToken

        # Add the content-type to the header.
        $header.Add('Content-Type', $JSON_HEADER)

        # Get URL for /certificates.
        $url = Get-CertificateUrl $ovcHostname

        # Create a JSON body for the add certificate action.
        $body = @{certificate="$certData"}
        $body = $body | ConvertTo-Json

        # Issue the POST operation and expect a response object in return.
        $skipCertParam = Get-SkipCertificateFlag
        $response = Invoke-RestMethod -Header $header -Uri $url -Method Post -Body $body @skipCertParam

        # Print out the response object.
        Write-Output $response
    }
}

Export-ModuleMember -function Add-HPESvtCertificate
