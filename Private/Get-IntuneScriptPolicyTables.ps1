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
#region Get-IntuneScriptPolicyTables
Function Get-IntuneScriptPolicyTables
{
    [array]$scriptPolicies = Get-IntuneScriptPolicies -LogPath $script:MDMDiagReportPathVariable

    $htmlBody = ""

    $areaTitleString = '📜 Intune Scripts'
    $statString = "TotalIntuneScriptPolicies: {0}" -f $scriptPolicies.Count

    $htmlBody = ""
    $htmlBody += "<div class='group-container'>"
    $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
    $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
    $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
    $htmlBody += "</div>"
    $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
    $htmlBody += "<div class='collapsible-content'>"

    foreach ($script in ($scriptPolicies | Sort-Object -Property PolicyID)) 
    {
        $htmlBody += "<div class='app-container'>"
        $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>" 
        $htmlBody += "<button class='toggle-button-inner' onclick='toggleContent(this)'>Hide</button>" 
        $htmlBody += "<h2 class='policy-area-title'>ScriptID: $($script.PolicyID)</h2>"
        $htmlBody += "</div>" 
        $htmlBody += "<div class='collapsible-content'>" 
        $htmlBody += "<table class='main-table'>"
        foreach ($property in $script.PSObject.Properties) 
        {
            $propertyName = $property.Name
            Switch ($property.Name)
            {
                'UserId'
                {
                    if ($property.Value -eq '00000000-0000-0000-0000-000000000000') 
                    {
                        # this is a device script, so we can set the value to "Device" with icon
                        $property.Value = "💻 Device"
                    } 
                    else 
                    {
                        $property.Value = "👤 {0}" -f $property.Value
                    }
                }
            
                'PreRemediationDetectScriptOutput'
                {
                    $propertyName = 'PreRemediationDetectScriptOutput 🔍'
                }

                'PostRemediationDetectScriptOutput'
                {
                    $propertyName = 'PostRemediationDetectScriptOutput 🛠️'
                }


                { $_ -in @('ResultDetails','Info','Schedule')}
                {
                    $property.Value = Get-HTMLTableFromData -InputData $property.Value
                }

                'ErrorCode'
                {
                    if ($property.Value -ne 0)
                    {
                        $property.Value = '⚠️ {0}' -f $property.Value
                    }    
                }
            }

            $htmlBody += "<tr><td style='font-weight: bold; width: 300px;'>$($propertyName)</td><td>$($property.Value)</td></tr>"
        }

        $htmlBody += "</table>"
        $htmlBody += "</div>"  # Close collapsible-content
        $htmlBody += "<br>"
    }

    $htmlBody += "</div>"  # Close collapsible-content
    $htmlBody += "</div>"  # Close group-container
    return $htmlBody
}
#endregion