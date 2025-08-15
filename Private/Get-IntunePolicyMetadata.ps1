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
#region Get-IntunePolicyMetadata
function Get-IntunePolicyMetadata
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [string]$PolicyAreaName,
        [Parameter(Mandatory = $true)]
        [string]$PolicyName,
        [Parameter(Mandatory = $true)]
        $MDMData
    )

    $outObj = [pscustomobject]@{
        RedirectionPath = "Redirection path not set"
        DefaultValue = "No default value set"
    }

    # PolicymetaData is a collection of metadata for each policy 
    # We are interested in the regpah or translationDllPath for the specific policy
    $policyMetaData = $MDMData.MDMEnterpriseDiagnosticsReport.PolicyManagerMeta.AreaMetadata | Where-Object { $_.PolicyAreaName -eq $PolicyAreaName }
    if (-not $policyMetaData) 
    {
        return $outObj
    }
    else 
    {
        $policy = $policyMetaData.PolicyMetadata | Where-Object { $_.PolicyName -eq $PolicyName } 
        if (-not $policy) 
        {
            return $outObj
        }
        else 
        {
            if (-NOT ([string]::IsNullOrEmpty($policy.value))) 
            {
                # If the policy has a value, return it as the default value
                $outObj.DefaultValue = $policy.value
            }

            # If the policy has a RegKeyPathRedirect, return it
            if (-NOT ([string]::IsNullOrEmpty($policy.RegKeyPathRedirect))) 
            {
                $outObj.RedirectionPath = 'RegKeyPathRedirect: {0}' -f $policy.RegKeyPathRedirect
            }

            # If the policy has a translationDllPath, return it
            if(-not ([string]::IsNullOrEmpty($policy.translationDllPath)))
            {
                $outObj.RedirectionPath = 'TranslationDllPath: {0}' -f $policy.translationDllPath
            }

            # If the policy has a grouppolicyPath, return it
            if(-not ([string]::IsNullOrEmpty($policy.grouppolicyPath)))
            {
                $outObj.RedirectionPath = 'GroupPolicyPath: {0}' -f $policy.grouppolicyPath
            }   

            # precheckDllPath
            if(-not ([string]::IsNullOrEmpty($policy.precheckDllPath)))
            {
                $outObj.RedirectionPath = 'PrecheckDllPath: {0}' -f $policy.precheckDllPath
            }

            # GPBlockingRegKeyPath
            if(-not ([string]::IsNullOrEmpty($policy.GPBlockingRegKeyPath)))
            {
                $outObj.RedirectionPath = 'GPBlockingRegKeyPath: {0}' -f $policy.GPBlockingRegKeyPath
            }
        }
    }
    return $outObj
}
#endregion
