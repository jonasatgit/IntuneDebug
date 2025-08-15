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
#region Get-EnterpriseApplicationHTMLTables
function Get-EnterpriseApplicationHTMLTables 
{
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$GroupedPolicies
    )

    $htmlBody = ""

    $enterpriseAppGroup = $GroupedPolicies.Where({ $_.Name -eq 'EnterpriseDesktopAppManagement' })

    $areaTitleString = '📦 EnterpriseDesktopAppManagement'
    $statString = "TotalAppPolicies: {0}" -f $enterpriseAppGroup.Group.Count

    $htmlBody = ""
    $htmlBody += "<div class='group-container'>"
    $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
    $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
    $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
    $htmlBody += "</div>"
    $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
    $htmlBody += "<div class='collapsible-content'>"

    foreach ($app in $enterpriseAppGroup.Group)
    {

        $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>" 
        $htmlBody += "<button class='toggle-button-inner' onclick='toggleContent(this)'>Hide</button>" 
        $htmlBody += "<h2 class='policy-area-title'>App: $($app.possibleAppName)</h2>"
        $htmlBody += "</div>" 
        $htmlBody += "<div class='collapsible-content'>" 
        $htmlBody += "<table class='main-table'>"

        # Let's exclude some properties that are not relevant for the report
        $excludedProperties = @('PossibleAppName','ActionType', 'AssignmentType', 'BITSJobId', 'JobStatusReport', 'PolicyScope', 'ServerAccountID', 'PackageId', 'LocURI', 'PackageType')

        foreach ($property in ($app.PSObject.Properties))
        {
            if ($property.Name -in $excludedProperties) 
            {
                continue
            }

            $value = Invoke-EscapeHtmlText -Text ($property.Value)
            $htmlBody += "<tr><td style='font-weight: bold; width: 400px;'>$($property.Name)</td><td>$value</td></tr>"
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