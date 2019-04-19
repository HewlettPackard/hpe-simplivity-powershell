#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

$JSON_HEADER = 'application/vnd.simplivity.v1.10+json'
$BEGIN_CERTIFICATE = '-----BEGIN CERTIFICATE-----'
$END_CERTIFICATE = '-----END CERTIFICATE-----'
$CRED_XML_PATH = Join-Path $HOME HPESvtCertificate.ps1.credential

function SetCredXml {
    param(
        $configObject
    )
    if (!(Get-IsPowerShellCore)) { #Export/Import-Clixml with encrypted content not supported on PowerShell Core
        $configObject.AccessToken = ConvertTo-SecureString $configObject.AccessToken -AsPlainText -Force
    }
    $configObject | Export-Clixml $CRED_XML_PATH -Force
    return $CRED_XML_PATH
}

function GetCredXml {
    if (![System.IO.File]::Exists($CRED_XML_PATH)) {
        throw "Could not authenticate. Run Get-HPESvtAuthToken to authenticate."
    }
    
    $configObject = Import-Clixml $CRED_XML_PATH
    if (!(Get-IsPowerShellCore)) { #Export/Import-Clixml with encrypted content not supported on PowerShell Core
        $configObject.AccessToken = (New-Object PSCredential "user",$configObject.AccessToken).GetNetworkCredential().Password
    }
    return $configObject
}

function Get-IsPowerShellCore {
    $PSVersionTable.PSEdition -and $PsVersionTable.PSEdition -eq 'Core'
}

function Get-BaseUrl {
    param(
        [string] $hostname
    )

    'https://' + $hostname + '/api/'
}

function Get-CertificateUrl {
    param(
        [string] $hostname
    )

    $baseUrl = Get-BaseUrl $hostname
    return $baseUrl + 'certificates'
}

function Get-Header {
    param(
        [string] $accessToken
    )

    @{
        'Authorization' = ("Bearer {0}" -f $accessToken);
        'Accept'=$JSON_HEADER
    }
}


# Add -SkipCertificateCheck flag if on PowerShell Core. This flag only exists in PowerShell 6.0 or later.
# There is an alternate way to do this on earlier versions of PowerShell, so just set this for PowerShell Core.
function Get-SkipCertificateFlag {
    $skipCertificateFlag = @{}
    if (Get-IsPowerShellCore) {
        $skipCertificateFlag.add("SkipCertificateCheck", $true)  
    }
    $skipCertificateFlag
}

# Skip certificate checking for 5.1. For some reason the standard way of disabling certificate checking does not
# work when connecting to the VmWare HMS, but this snippet of C# does.
# Force Tls version to 1.2. This fixes a defect when connecting to a system with Tls 1.0 disabled.
function Skip-CertificateCheck {
Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback {
        public static void Ignore() {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@
    [ServerCertificateValidationCallback]::Ignore();
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

# Get X509Certificate2 from base64 encoded string from the server.
# This will include Begin/End Certificate strings and newlines that need to be trimmed.
function Get-CertificateFromBase64String {
    param(
        [string] $base64String
    )
    $base64String = $base64String.Trim()
    $base64String = $base64String.Trim($BEGIN_CERTIFICATE)
    $base64String = $base64String.Trim($END_CERTIFICATE)
    $byteArray = [System.Convert]::FromBase64String($base64String)
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::New($byteArray)
    Write-Output $cert
}

# see table at https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
function Get-IsRunningNet47 {

    # Core has everything we need for 4.7 interop
    if (Get-IsPowerShellCore) {
        return;
    }

    $running = Get-CheckDotNetVersion -version 460805
    if ($running -eq $false)
    {
        throw "This cmdlet requires .net 4.7"
    }

}

function Get-CheckDotNetVersion {
    param(
        [int] $version
    )

    try {

        $installed = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full')
        if ($version -gt $installed.Release)
        {
            return $false
        }

        return $true
    }
    catch {
        Write-Error "Error while determining .NET version"       
    }

    return $false        
}
