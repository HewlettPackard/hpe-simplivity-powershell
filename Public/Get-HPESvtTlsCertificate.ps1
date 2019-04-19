#
# (c) Copyright 2019 Hewlett Packard Enterprise Development LP
#

$Code = @'
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

namespace CertificateCaptureUtility
{
    public class HttpCallbackDelegate
    {
         public static Func<HttpRequestMessage,X509Certificate2,X509Chain,SslPolicyErrors,Boolean> ValidationCallback = 
            (message, cert, chain, errors) => 
            {
                var newCert = new X509Certificate2(cert);
                
                CertificateResults.Add(new CertificateResult() { Certificate =  newCert, PolicyErrors = errors});
                return true; 
           };

        public static List<CertificateResult> CertificateResults = new List<CertificateResult>();
    }

    public class CertificateResult 
    {
        public X509Certificate2 Certificate { get; set; }
        public SslPolicyErrors PolicyErrors { get; set; }
    }
}
'@

function Get-HPESvtTlsCertificate
{
    <# 
        .SYNOPSIS
        Extracts a TLS certificate from a TLS endpoint.  Requires .net 4.7

        .DESCRIPTION
        Extracts a TLS certificate from a TLS endpoint.

        .PARAMETER HostName
        Specifies the hostname or ip address of the TLS endpoint.  Defaults
        to port 443, but other ports can be targetted by supplying port after
        : delimiter.   Note connections to HyperV hosts and SCVMM should add 
        the default winrm HTTPS port (:5986)

        .EXAMPLE
        # Get a cert from a TLS endpoint
        Get-HPESvtTlsCertificate -HostName "10.1.1.1"
    #>
    [CmdletBinding()]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]

    param
    (
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $HostName
    )
    
    Get-IsRunningNet47

    $isValidatorClassLoaded = $null -ne (([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -eq $false }) | Where-Object { $_.DefinedTypes.FullName -contains 'CertificateCaptureUtility.HttpCallbackDelegate' }) 

    if ($isValidatorClassLoaded -eq $false)
    { 
        if ($PSEdition -ne 'Core')
        {
            Add-Type -AssemblyName System.Net.Http
            Add-Type $Code -ReferencedAssemblies System.Net.Http -ErrorAction Stop 
            [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        } 
        else 
        {
            Add-Type $Code
        }
    }
    
    try {

        $certs = [CertificateCaptureUtility.HttpCallbackDelegate]::CertificateResults

        $handler = [System.Net.Http.HttpClientHandler]::new()
        $handler.ServerCertificateCustomValidationCallback = [CertificateCaptureUtility.HttpCallbackDelegate]::ValidationCallback
        $client = [System.Net.Http.HttpClient]::new($handler)
    
    }
    catch {
        Write-Error "Error creating HTTP client"
    }

     # append port if not specified
     if ($HostName -notlike '*:*') {
        $HostName = $HostName + ":443"
    }
   
    $result = $client.GetAsync("https://" + $HostName).Result 
    if ($null -eq $result)
    {
        throw "Couldn't connect to " + $HostName;
    }

    $ret = $certs[-1].Certificate;
    if ($null -eq $ret)
    {
        throw "Couldn't harvest a certificate from " + $HostName;
    }

    $certs.Clear();
    return $ret;
}

Export-ModuleMember -function Get-HPESvtTlsCertificate 
