<#
.SYNOPSIS
    This function attempts to parse a string into a DateTime object using a set of known formats.
 
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
#region Get-CertificateDetailsByThumbprint
function Get-CertificateDetailsByThumbprint 
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [string[]]$Thumbprints
    )

    [array]$certList = Get-ChildItem Cert:\LocalMachine -Recurse 

    $outList = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($item in $thumbprints)
    {
        [array]$tmpCert = $certList | Where-Object { $_.Thumbprint -eq $item }
        if ($tmpCert) 
        {

            [array]$tmpStoreName = $tmpCert.pspath -replace '.*?Certificate::[^\\]+\\([^\\]+)\\.*', '$1' -replace 'CA', 'Intermediate CA' -replace 'Root', 'Root CA'

            $outList.Add([pscustomobject]@{
                Info = "Found in $($tmpStoreName.count) store(s)"
                Store = ($tmpStoreName -join ', ')
                Issuer = $tmpCert[0].Issuer -replace '^CN='
                IssuedTo = ($tmpCert[0].Subject -replace '^.*CN=([^,]+),.*$', '$1' -replace '^CN=')
                Thumbprint = $item
                ValidFrom = $tmpCert[0].NotBefore
                ValidTo = $tmpCert[0].NotAfter
                ExpireDays = try{[math]::Round(($tmpCert[0].NotAfter - (Get-Date)).TotalDays, 2)} catch { 'N/A' }
            })
        }
        else 
        {
            $outList.Add([pscustomobject]@{
                Info = 'Not found'
                Store = ''
                Issuer = ''
                IssuedTo = ''
                Thumbprint = $item
                ValidFrom = ''
                ValidTo = ''
                ExpireDays = ''
            })
        }
    }
    return $outList
}
#endregion