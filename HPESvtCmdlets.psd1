#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#
#
# Module manifest for module 'HPESvtCmdlets'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'HPESvtCmdlets.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '51acca13-ea6b-463f-bd7f-9f2ce3c9ac84'

# Author of this module
Author = 'Hewlett-Packard Enterprise'

# Company or vendor of this module
CompanyName = 'Hewlett-Packard Enterprise'

# Copyright statement for this module
Copyright = '(c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP'

# Description of the functionality provided by this module
Description = 'HPE SimpliVity cmdlets perform REST API operations to the HPE SimpliVity system.
These cmdlets can be used to get and set HPE SimpliVity data and invoke actions on the HPE Simplivity system.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
DotNetFrameworkVersion = '4.7.1'

# Compatible PowerShell Editions for this module
CompatiblePSEditions = 'Desktop', 'Core'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Add-HPESvtCertificate',
                      'Get-HPESvtCertificate',
                      'Get-HPESvtRootCertificate',
                      'Get-HPESvtTlsCertificate',
                      'Remove-HPESvtCertificate',
                      'Get-HPESvtAuthToken'
                    )

# List of all files packaged with this module
FileList = @('HPESvtCmdlets.psm1',
             'HPESvtCmdlets.psd1',
             'Public/Add-HPESvtCertificate.ps1',
             'Public/Get-HPESvtCertificate.ps1',
             'Public/Get-HPESvtRootCertificate.ps1',
             'Public/Get-HPESvtTlsCertificate.ps1',
             'Public/Remove-HPESvtCertificate.ps1',
             'Public/Get-HPESvtAuthToken.ps1',
             'Private/Get-Utils.ps1',
             'LICENSE'
            )

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Hewlett','Packard','Enterprise','HPE','REST','RESTful','Svt','SimpliVity', 'OmniStack')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/HewlettPackard/hpe-simplivity-powershell/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/HewlettPackard/hpe-simplivity-powershell'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'HPESvtCmdlets - Version 1.0.0.0
Enhancements and fixes:
  - Initial release with authentication and REST API Certificate support

Known Issues:
  - None

HPE SimpliVity PowerShell Information:
https://api.simplivity.com'


    } # End of PSData hashtable

} # End of PrivateData hashtable

# UNUSED Items

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = '*'

# Aliases to export from this module
# AliasesToExport = '*'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

