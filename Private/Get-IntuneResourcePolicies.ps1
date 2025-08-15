<#
.SYNOPSIS
    Function
 
.DESCRIPTION
    #************************************************************************************************************
    # Disclaimer
    #
    # This sample script is not supported under any Microsoft standard support program or service. This sample
    # script is provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties
    # including, without limitation, any implied warranties of merchantability or of fitness for a particular
    # purpose. The entire risk arising out of the use or performance of this sample script and documentation
    # remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation,
    # production, or delivery of this script be liable for any damages whatsoever (including, without limitation,
    # damages for loss of business profits, business interruption, loss of business information, or other
    # pecuniary loss) arising out of the use of or inability to use this sample script or documentation, even
    # if Microsoft has been advised of the possibility of such damages.
    #
    #************************************************************************************************************

#>
#region Get-IntuneResourcePolicies
function Get-IntuneResourcePolicies
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        $MDMData
    )


    $outList = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($enrollment in $MDMData.MDMEnterpriseDiagnosticsReport.Resources.Enrollment)
    {
        $enrollmentID = $enrollment.enrollmentid

        foreach ($scope in $enrollment.Scope)
        {
            $resourceTarget = $scope.ResourceTarget
            #$scope.ChildNodes.'#Text'
            foreach ($resource in $scope.Resources.ChildNodes.'#Text')
            {
                # Setting $matches to null to avoid issues with previous matches
                $matches = $null
                if (($resource -match '^\d+$') -or ($resource -match '^default$'))
                {
                    continue
                }

                # Setting $matches to null to avoid issues with previous matches
                $matches = $null
                $tmpResourceType = 'Unknown'
                if ($resource -match "Vendor/[^/]+/([^/]+)") 
                {
                    $tmpResourceType = $matches[1]
                }

                $tmpCertObj = [pscustomobject]@{
                    CertStore = $null
                    Issuer = $null
                    IssuedTo = $null
                    Thumbprint = $null
                    ValidFrom = $null
                    ValidTo = $null
                    ExpireDays = $null
                }

                # running locally?
                $tmpSubject = ''
 
                $boolCertResource = $false
                switch -Regex ($resource) 
                {
                    'RootCATrustedCertificates\/Root' 
                    {
                        $certPath = "Cert:\{0}\Root\{1}"
                        $certStoreName = 'Root CA'
                        $boolCertResource = $true
                    }

                    'RootCATrustedCertificates\/CA'
                    {
                        $certPath = "Cert:\{0}\CA\{1}"
                        $certStoreName = 'Intermediate CA'
                        $boolCertResource = $true
                    }
                    'RootCATrustedCertificates\/TrustedPublisher' 
                    {
                        $certPath = "Cert:\{0}\TrustedPublisher\{1}"
                        $certStoreName = 'Trusted Publisher'
                        $boolCertResource = $true
                    }
                }

                if($boolCertResource)
                {
                    # Determine the certificate store type based on the resource path
                    switch -Regex ($resource) 
                    {
                        '^\.\/device\/' { $tmpPathType = 'LocalMachine'; break }
                        '^\.\/user\/'   { $tmpPathType = 'CurrentUser'; break }
                        default         { $tmpPathType = 'LocalMachine' }
                    }
                
                    # Lets get the certificate details by thumbprint
                    $tmpThumbprint = $resource | Split-Path -Leaf -ErrorAction SilentlyContinue
                    # Addind the middle part to the path string at the thumbprint at the end
                    $certPath = $certPath -f $tmpPathType, $tmpThumbprint

                    if (Test-Path $certPath) 
                    {
                        # Looking for a cert locally
                        [array]$cert = Get-Item -Path "$certPath" -ErrorAction SilentlyContinue
                    }
                    if ($cert) 
                    {
                        $resource = '{0} ➡️ {1}' -f $resource,  ($cert.Subject -replace '^.*CN=([^,]+),.*$', '$1' -replace '^CN=')
                        $tmpCertObj.CertStore = $certStoreName
                        $tmpCertObj.IssuedTo = ($cert.Subject -replace '^.*CN=([^,]+),.*$', '$1' -replace '^CN=')
                        $tmpCertObj.Issuer = $cert.Issuer -replace '^CN='
                        $tmpCertObj.Thumbprint = $tmpThumbprint
                        $tmpCertObj.ValidFrom = $cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
                        $tmpCertObj.ValidTo = $cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
                        $tmpCertObj.ExpireDays = try{[math]::Round(($cert.NotAfter - (Get-Date)).TotalDays, 2)} catch { 'N/A' }
                    }
                    else 
                    {
                        $resource = '{0} ➡️ {1}' -f $resource,  ($cert.Subject -replace '^.*CN=([^,]+),.*$', '$1' -replace '^CN=')
                        $tmpCertObj.CertStore = $certStoreName
                        $tmpCertObj.IssuedTo = $null
                        $tmpCertObj.Issuer = $null
                        $tmpCertObj.Thumbprint = $tmpThumbprint
                        $tmpCertObj.ValidFrom = $null
                        $tmpCertObj.ValidTo = $null
                        $tmpCertObj.ExpireDays = $null                  
                    }
                }
                
                # Putting it all together
                $outObj = [pscustomobject]@{
                    PolicyScope = 'Resource'
                    EnrollmentId = $enrollmentID
                    ProviderID = $script:enrollmentProviderIDs[$enrollmentID]
                    ResourceTarget = $resourceTarget
                    ResourceName = $resource
                    ResourceType = $tmpResourceType    
                    ResourceData = if($boolCertResource){$tmpCertObj}else{$null}
                }
                $outList.Add($outObj)
            }
            
        }
    }
    return $outList
}
#endregion