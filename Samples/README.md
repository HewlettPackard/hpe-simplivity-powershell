
# CMDLet Sample Scripts

This directory contains sample scripts using the HPE Simplivity Powershell Cmdlet.  These scripts are primarily designed to perform triage and support operations on systems running Omnistack 3.7.8 and newer.


# vcenterdiag.ps1

This script is a one stop diagnostic tool for troubleshooting vCenter certificate issues. 
 
When run, it performs the following diagnostics:

* Grabs the contents from the OVC's Certificate Trust Store
* Grabs the .zip file from the vCenter HTTP root - this .zip file contains the certificates corresponding to the vmware PKI
* Grabs the leaf certificate from the vCenter endpoint
* Dumps the details from the vCenter certificate, including warning the user of potential name issues 
* Builds a certificate chain for the leaf certificate against the OVC's certificate trust store
* Builds a certificate chain for the leaf certificate against the .zip file downloaded from the vCenter
 

This script can be used to determine next steps in fixing HMS authentication issues due to missing TLS certificates.

# disabletlsvalidation.ps1

This script invokes "big red button" policy, effectively turning off TLS chain validation for troubleshooting unavailability issues.

# harvesthmscerts.ps1

This script allows the user to grab the .zip file containing the VMWare public key infrastructure from the vCenter server, and plumbs them into the OVC Certificate Trust Store.

# hostdiag.ps1

This script is a one stop diagnostic tool for troubleshooting any TLS connection certificate issues. It is specifically designed to make certain that the certificate for an ESXi or HyperV host can chain to the OVC Certificate Trust store, but it can be used for testing chaining for any TLS endpoint.  

Note, for some usages, the connection relies upon "pinned" certificates.  This is a trust established against an individual certificate (identified by thumbprint), rather than an entire public key infrastructure.
 
The script has 2 different functions, which can be incorporated in other scripts, or run with a manually edited script.

## Get-HostStatus
Grabs the contents from the OVC's Certificate Trust Store
Get the leaf certificate from a TLS connection to the designated host / port
Build a certificate chain for the TLS certificate using the OVC's Certificate Trust Store
Note - it will also log "pinned" if the leaf certificate is present in the Certificate Trust Store

## Add-PKIForHost (Windows only)
For some scenarios, unknown elements of the certificate chains may already be present on the Windows system as part of the customer's internal PKI.  This function allows support to retrieve those certificates from the WIndows workstation, and post them to the OVC's Certificate Trust Stores.
Get the leaf certificate from a TLS connection to the designated host / port
Grab the missing elements of the chain, if possible, from Windows Certificate Stores.
Install the missing elements of the chain in the OVC Certificate Trust Store


# update-vcenter-cert.ps1
This script is used when moving between vcenters. It effectively harvests the certificates from both the source and destination vcenter, plumbs them into the OVC Certificate Trust Store, allowing trusted communications between the OVC and both vCenters.