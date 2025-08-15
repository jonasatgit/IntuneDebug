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
#region Get-IntuneDeviceAndUserPolicies
Function Get-IntuneDeviceAndUserPolicies
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        $MDMData
    )

    $userInfoHash = Get-LocalUserInfo

    $outObj = [System.Collections.Generic.List[pscustomobject]]::new()
    # Iterate through each ConfigSource item in the XML
    foreach ($item in $MDMData.MDMEnterpriseDiagnosticsReport.PolicyManager.ConfigSource)
    {
        $enrollmentID = $item.EnrollmentId
        
        foreach ($PolicyScope in $item.PolicyScope)
        {
            $PolicyScopeName = $PolicyScope.PolicyScope

            foreach ($area in $PolicyScope.Area)
            {
                if ($area.PolicyAreaName -ieq 'knobs')
                {
                    # Skip the 'knobs' area
                    continue
                }

                # Define the properties we are interested in 
                [array]$propertyList = $area | Get-Member | 
                                            Where-Object {$_.MemberType -eq 'Property'} | 
                                            Select-Object -Property Name | 
                                            Where-Object {$_.Name -notlike '*_LastWrite' -and $_.Name -ne 'PolicyAreaName'}

                try{$enrollmentProvider = $script:enrollmentProviderIDs[$enrollmentID]}catch{}                
                if([string]::IsNullOrEmpty($enrollmentProvider))
                {
                    $enrollmentProvider = 'Unknown'
                }

                try{$userName = $userInfoHash[$PolicyScopeName]}catch{}
                if([string]::IsNullOrEmpty($userName))
                {
                    $userName = 'Unknown'
                }

                $tmpObj = [pscustomobject]@{
                                EnrollmentId = $enrollmentID
                                EnrollmentProvider = $enrollmentProvider
                                PolicyScope  =  $PolicyScopeName
                                PolicyScopeDisplay = if ($PolicyScopeName -eq 'Device') { $PolicyScopeName } else { $userName }
                                PolicyAreaName = $area.PolicyAreaName
                                SettingsCount = $propertyList.Count
                                Settings = ""
                            }

                $settingsList = [System.Collections.Generic.List[pscustomobject]]::new()
                foreach ($property in $propertyList)
                {
                    # Adding metadata for the property
                    $metadataInfo = Get-IntunePolicyMetadata -MDMData $MDMData -PolicyAreaName $area.PolicyAreaName -PolicyName $property.Name
                    if ($area.PolicyAreaName -ieq 'knobs')
                    {
                        $winningProvider = "Not set"
                    }
                    else 
                    {
                        $currentPolicyInfo = Get-IntunePolicyCurrentData -PolicyScope $PolicyScopeName -PolicyAreaName $area.PolicyAreaName -PolicyName $property.Name -MDMData $MDMData
                        if ($null -eq $currentPolicyInfo)
                        {
                            $winningProvider = "Not set"    
                        }
                        else 
                        {
                            $winningProvider = $currentPolicyInfo | Select-Object -ExpandProperty "$($property.Name)_WinningProvider"
                        }
                    }                    

                    $settingsList.Add([pscustomobject][ordered]@{
                        Name = $property.Name
                        Value = $area.$($property.Name)
                        WinningProvider = $winningProvider
                        Metadata = $metadataInfo
                    })
                }

                $tmpObj.Settings = $settingsList   
                
                # Add the tmpObj to the $outObj
                $outObj.Add($tmpObj)
            }
        }
    }

    return $outObj
}
#endregion