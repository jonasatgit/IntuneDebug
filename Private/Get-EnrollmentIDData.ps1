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
#region Get-EnrollmentIDData
function Get-EnrollmentIDData
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [string]$EnrollmentId,
        [Parameter(Mandatory = $true)]
        $MDMData
    )

    $enrollmentObj = $MDMData.MDMEnterpriseDiagnosticsReport.Enrollments.Enrollment | Where-Object {$_.EnrollmentId -eq $EnrollmentId} 
    # If no enrollment object is found, return null
    if (-not $enrollmentObj) 
    {
        #Write-Error "Enrollment ID '$EnrollmentId' not found."
        return $null
    }
    else
    {
        return [pscustomobject][ordered]@{
            EnrollmentId = $enrollmentObj.EnrollmentId
            EnrollmentState = $enrollmentObj.EnrollmentState
            EnrollmentType = $enrollmentObj.EnrollmentType
            CurCryptoProvider = $enrollmentObj.CurCryptoProvider
            DiscoveryServiceFullURL = $enrollmentObj.DiscoveryServiceFullURL
            DMServerCertificateThumbprint = $enrollmentObj.DMServerCertificateThumbprint
            IsFederated = $enrollmentObj.IsFederated
            ProviderID = if ($null -eq $enrollmentObj.ProviderID) 
            {
                'Local'
            }
            elseif ($enrollmentObj.ProviderID -eq 'MS DM Server') 
            {
                'Intune'
            }
            else
            {
                $enrollmentObj.ProviderID
            }

            RenewalPeriod = $enrollmentObj.RenewalPeriod
            RenewalErrorCode = $enrollmentObj.RenewalErrorCode
            RenewalROBOSupport = $enrollmentObj.RenewalROBOSupport
            RenewalStatus = $enrollmentObj.RenewalStatus
            RetryInterval = $enrollmentObj.RetryInterval
            RootCertificateThumbPrint = $enrollmentObj.RootCertificateThumbPrint
            IsRecoveryAllowed = $enrollmentObj.IsRecoveryAllowed
            DMClient = $enrollmentObj.DMClient
            Poll = $enrollmentObj.Poll
            FirstSync = $enrollmentObj.FirstSync
            UserFirstSync = $enrollmentObj.UserFirstSync
            Push = $enrollmentObj.Push
        }
    }
}
#endregion