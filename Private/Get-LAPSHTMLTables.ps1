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
#region Get-LAPSHTMLTables
Function Get-LAPSHTMLTables
{
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$GroupedPolicies
    )

    $infoData = $GroupedPolicies.Where({ $_.Name -eq 'LAPS' }) 

    $areaTitleString = "🔑 Local Admin Password Solution (LAPS)"

    if ($infoData) 
    {
        $statString = "LAPS policy: 1"
    }
    else 
    {
        $statString = "LAPS policy: 0"
    }
    
    $htmlBody = "" 
    $htmlBody += "<div class='group-container'>"
    $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
    $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
    $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
    $htmlBody += "</div>"
    $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
    $htmlBody += "<div class='collapsible-content'>"
    

    foreach ($item in $infoData.group) 
    {
        $htmlBody += "<table class='main-table'>"
        $htmlBody += "<tr style='border-top: 3px solid #ddd;'><th style='font-weight: bold; width: 300px;'>Setting ⚙️</th><th>Value</th></tr>"
        foreach ($property in ($item.PSObject.Properties)) 
        {
            #skip properties that are not relevant for the report
            if ($property.Name -in @('PolicyScope')) 
            {
                continue
            }
            $htmlBody += "<tr><td style='font-weight: bold; width: 300px;'>$($property.Name)</td><td>$($property.Value)</td></tr>"
        }
        $htmlBody += "</table>"
        $htmlBody += "<br>"
    }

    $htmlBody += "</div>"  # Close collapsible-content
    $htmlBody += "</div>"  # Close group-container
    return $htmlBody
}
#endregion