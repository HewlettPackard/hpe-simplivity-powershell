#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

<# 
 .SYNOPSIS
  Retrieve the root certificates from the HMS.

 .DESCRIPTION
  Retrieve the root certificates from the Hypervisor Management System (HMS).

 .PARAMETER HostName
  The hostname or IP of the Hypervisor Management System (HMS).

 .EXAMPLE
   # Show usage.
   Get-HPESvtRootCertificate

 .EXAMPLE
   # Get the HMS root certificates
   Get-HPESvtRootCertificate -HostName host1
#
#>

function Get-HPESvtRootCertificate {
    [CmdletBinding()]   
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $HostName
    )

    # The following lines are specific to PowerShell 5 and can be removed when we drop support for it.
    # They work around 'The underlying connection was closed' errors from Invoke-RestMethod.
    Skip-CertificateCheck
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Get zip file of root certificates from HMS.
    $url = 'https://' + $HostName + '/certs/download.zip'
    $skipCertParam = Get-SkipCertificateFlag
    $certZipFile = New-TemporaryFile
    Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop -Outfile $certZipFile @skipCertParam
   
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $ZipFile = [System.IO.Compression.ZipFile]
    $zipArchive = $ZipFile::OpenRead($certZipFile)
	$zipEntries = @()

    # Get compressed files.
    $entries = $zipArchive.Entries | Where-Object { $_.Name -match ".*crt$"}

    foreach ($entry in $entries) {
        Write-Verbose "Received certificate: $entry"
        $stream = $entry.Open()

        $reader = New-Object IO.StreamReader($stream)
        $text = $reader.ReadToEnd()
        $cert = Get-CertificateFromBase64String $text
        $zipEntries += $cert

        $reader.Close()
        $stream.Close()
    }
    $zipArchive.Dispose()

    # Return the auth result.
    Write-Output $zipEntries
}

Export-ModuleMember -function Get-HPESvtRootCertificate
