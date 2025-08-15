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
#region Get-EnrollmentProviderIDs
function Get-EnrollmentProviderIDs
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        $MDMData
    )
    
    $enrollmentHashTable = @{}
    foreach($enrollment in $MDMData.MDMEnterpriseDiagnosticsReport.Enrollments.Enrollment)
    {
        $providerID = $enrollment.ProviderID
        if ($enrollment.EnrollmentId -match '[a-fA-F0-9\-]{36}')
        {
            If([string]::IsNullOrEmpty($enrollment.ProviderID))
            {
                # Logic to get a ppkg file name from the MDMEnterpriseDiagnosticsReport
                $providerPackage = $MDMData.MDMEnterpriseDiagnosticsReport.ProvisioningResults.Result | Where-Object -Property PackageID -eq "{$($enrollment.EnrollmentId)}"
                if ($providerPackage)
                {
                    $providerID = $providerPackage.PackageFileName
                }
                else 
                {                    
                    $providerID = 'Local'
                    try 
                    {
                        # try to extract the enrollment name from a string like this:
                        # '<td valign="top" class="ColumnHeader">EnrollmentEnrollTypeUpdatePolicy</td><td valign="top">B04F44A4-B696-4B56-934A-C11667E944E4</td>'
                        $content = Get-Content -Path $script:MDMDiagHTMLReportPathVariable -Raw
                        $pattern = '<td[^>]*>(?<EnrollmentName>[^<]+)</td>\s*<td[^>]*>' + [regex]::Escape($enrollment.EnrollmentId) + '</td>'
                        $regexResult = $null
                        $regexResult = [regex]::Match($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                        $providerID = $result.Groups['EnrollmentName'].Value
                    }
                    catch{}
                }
            }
            elseif ($enrollment.ProviderID -eq 'MS DM Server')
            {
                $providerID = 'Intune'
            }

            # Add the EnrollmentId and ProviderID to the hash table
            $enrollmentHashTable[$enrollment.EnrollmentId] = $providerID
        }
        else 
        {
            # If the EnrollmentId is not in the expected format, skip it
            continue
        }
    }

    return $enrollmentHashTable
}
#endregion
