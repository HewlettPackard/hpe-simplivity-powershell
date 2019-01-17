#
# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#

<# 
 .SYNOPSIS
  Authenticate to the HMS and get an OAuth token.

 .DESCRIPTION
  Authenticate to the HMS and get an OAuth token.

 .PARAMETER HostName
  The hostname or IP of the OmniStack Virtual Controller (OVC)

 .PARAMETER Credential
  A PSCredential object containing the credentials for the HMS hostname.
  Optionally, passing the username for the HMS hostname will result in a prompt for the password.

 .PARAMETER Emergency
  (Optional) Get an emergency token using the emergency access user instead of a standard admin user.

 .EXAMPLE
   # Show usage.
   Get-HPESvtAuthToken

 .EXAMPLE
   # Get a SimpliVity OAuth token
   Get-HPESvtAuthToken -HostName host1 -Credential user1

 .EXAMPLE
   # Get a SimpliVity emergency OAuth token
   Get-HPESvtAuthToken -HostName host1 -Credential user1 -Emergency
#
#>

function Get-HPESvtAuthToken {
    [CmdletBinding()]   
    param(
        [ValidateNotNullOrEmpty()] 
        [Parameter(Mandatory=$true)]
        [string] $HostName,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential] $Credential,
        [Parameter(Mandatory=$false)]
        [switch] $Emergency
    )

    # Allow the use of self signed certificates.
    Skip-CertificateCheck

    # Create a base64 encoding for HTTP authentication.
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "simplivity","")))

    # Create a JSON body with username, password, and grant_type.
    $body = @{
        username=$Credential.UserName;
        password=$Credential.GetNetworkCredential().Password
    }
    if ($Emergency) {
        $body.Add('grant_type', 'emergency')
    } else {
        $body.Add('grant_type', 'password')
    }

    # Authenticate user and generate access token.
    $oauthTokenUrl = 'oauth/token'
    $baseUrl = Get-BaseUrl $Hostname
    $url = $baseUrl + $oauthTokenUrl
    $header = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $skipCertParam = Get-SkipCertificateFlag
    $response= Invoke-RestMethod -Uri $url -Headers $header -Body $body -Method Post -ErrorAction Stop @skipCertParam
    $accessToken = $response.access_token;

    # Store the token
    if ($accessToken) {
        $svtToken = @{
            AccessToken=$accessToken
            HostName=$Hostname
        }
        SetCredXml $svtToken
    }

    # Return the auth result.
    Write-Output $response
}
