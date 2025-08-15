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
#region Get-DeviceAndUserHTMLTables
Function Get-DeviceAndUserHTMLTables
{
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$GroupedPolicies
    )

    $htmlBody = ""
    $selection = $GroupedPolicies.Where({($_.Name -eq 'Device') -or ($_.Name -match 'S-\d+(-\d+)+')})
    $deviceSelection = $GroupedPolicies.Where({ $_.Name -eq 'Device' })
    #$userSelection = $GroupedPolicies.Where({ $_.Name -match 'S-\d+(-\d+)+' })
    foreach ($group in $selection) 
    {
        if ($group.Name -eq 'Device') 
        { 
            $statString = "TotalPolicyAreas: {0}<br>TotalSettings: {1}" -f $deviceSelection.group.count, $deviceSelection.group.Settings.count
            $areaTitleString = '💻 Device'
        } 
        else 
        { 
            # We need to get the right numbers per user, not for all users together
            [array]$tmpUserStatsSelection = $GroupedPolicies.Where({ $_.Name -eq $group.Name})
            $tmpTotalAreas = 0
            $tmpTotalAreas = try{($tmpUserStatsSelection | Select-Object -Property Count).Count}catch{}
            $tmpTotalSettings = 0
            $tmpTotalSettings = $tmpUserStatsSelection.group.Settings.count

            $statString = "TotalPolicyAreas: {0}<br>TotalSettings: {1}" -f $tmpTotalAreas, $tmpTotalSettings

            if ([string]::IsNullOrEmpty($group.group[0].PolicyScopeDisplay)) 
            {
                $areaTitleString = '👤 {0}: Unknown'
            }
            else 
            {
                $areaTitleString = '👤 {0}: {1}' -f $group.Name, $group.group[0].PolicyScopeDisplay
            }
        }
        
        $htmlBody += "<div class='group-container'>"
        $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
        $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
        $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
        $htmlBody += "</div>"
        $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
        $htmlBody += "<div class='collapsible-content'>"
        
        $i = 0
        foreach ($policy in ($group.Group | Sort-Object -Property PolicyAreaName)) 
        {
            if ($i -gt 0) 
            {
                $htmlBody += "<br><br>"
            }

            $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>" 
            $htmlBody += "<button class='toggle-button-inner' onclick='toggleContent(this)'>Hide</button>" 
            $htmlBody += "<h2 class='policy-area-title'>PolicyArea: $($policy.PolicyAreaName)</h2>"
            $htmlBody += "</div>" 
            $htmlBody += "<div class='collapsible-content'>" 
            $htmlBody += "<table class='main-table'>"
            $htmlBody += "<tr><td style='font-weight: bold; width: 400px;'>EnrollmentId</td><td>$($policy.EnrollmentId) ➡️ $($policy.EnrollmentProvider)</td><td style='width: 150px;'></td><td style='width: 200px;'></td></tr>"
            $htmlBody += "<tr style='border-top: 3px solid #ddd;'><th style='font-weight: bold; width: 400px;'>Setting ⚙️</th><th>Value</th><th style='width: 150px;'>DefaultValue</th><th style='width: 200px;'>WinningProvider</th></tr>"

            foreach ($settings in $policy.Settings) 
            {
                $settingspath = 'Path or DLL of the setting: "{0}"' -f $settings.Metadata.RedirectionPath

                if ($settings.WinningProvider -eq 'Not set' -or [string]::IsNullOrEmpty($settings.WinningProvider)) 
                {
                    $winningProviderString = $policy.EnrollmentProvider
                } 
                else 
                {
                    $tmpValue = $script:enrollmentProviderIDs[$settings.WinningProvider]
                    if ($tmpValue) 
                    {
                        $winningProviderString = $tmpValue
                    }
                    else 
                    {
                        $winningProviderString = $settings.WinningProvider
                    }
                }

                if ($winningProviderString.Trim() -ne $policy.EnrollmentProvider.Trim()) 
                {
                    $winningProviderString = "ℹ️ $winningProviderString"
                } 

                $value = Invoke-EscapeHtmlText -Text ($settings.Value -replace '&quot;', '"')
                $defaultValue = $settings.Metadata.DefaultValue
                $htmlBody += "<tr><td class='setting-col'>$($settings.Name)</td><td title='$($settingspath)'>$value</td><td style='width: 150px;'>$defaultValue</td><td style='width: 200px;'>$winningProviderString</td></tr>"
            }

            $htmlBody += "</table>"
            $htmlBody += "</div>"  # Close collapsible-content
            $i++
        }
        $htmlBody += "</div>"  # Close collapsible-content
        $htmlBody += "</div>"  # Close group-container
    }

    return $htmlBody
}
#endregion