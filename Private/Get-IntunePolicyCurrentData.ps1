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
#region Get-IntunePolicyCurrentData
Function Get-IntunePolicyCurrentData
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [string]$PolicyScope,
        [Parameter(Mandatory = $true)]
        [string]$PolicyAreaName,
        [Parameter(Mandatory = $true)]
        [string]$PolicyName,
        [Parameter(Mandatory = $true)]
        $MDMData
    )
    
    # Define the policy scope to filter by
    [array]$PolicyScopeData = $MDMData.MDMEnterpriseDiagnosticsReport.PolicyManager.currentPolicies | Where-Object { $_.PolicyScope -eq $PolicyScope }

    # Search for the specific policy area and policy name
    $PolicyObj = $PolicyScopeData.CurrentPolicyValues | Where-Object { $_.PolicyAreaName -eq $PolicyAreaName} 

    # Looking for the specific policy name
    $resultObj = $PolicyObj | select-object -Property "$($PolicyName)_ProviderSet", "$($PolicyName)_WinningProvider"

    return $resultObj
}
#endregion
