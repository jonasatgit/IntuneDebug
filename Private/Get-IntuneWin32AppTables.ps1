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
#region Get-IntuneWin32AppTables
Function Get-IntuneWin32AppTables
{
    $win32Apps = Get-IntuneWin32AppPolicies -LogPath $script:MDMDiagReportPathVariable

    $htmlBody = ""

    $areaTitleString = '🪟 Win32Apps'
    $statString = "TotalWin32AppPolicies: {0}" -f $win32Apps.Count

    $htmlBody = ""
    $htmlBody += "<div class='group-container'>"
    $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
    $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
    $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
    $htmlBody += "</div>"
    $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
    $htmlBody += "<div class='collapsible-content'>"

    $excludedProperties = @('PolicyScope', 'ServerAccountID', 'PackageId')

    foreach ($app in $win32Apps) 
    {
        $htmlBody += "<div class='app-container'>"
        $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>" 
        $htmlBody += "<button class='toggle-button-inner' onclick='toggleContent(this)'>Hide</button>" 
        $htmlBody += "<h2 class='policy-area-title'>Win32App: $($app.Name)</h2>"
        $htmlBody += "</div>" 
        $htmlBody += "<div class='collapsible-content'>" 
        $htmlBody += "<table class='main-table'>"
        foreach ($property in ($app.PSObject.Properties | Sort-Object -Property Name | Where-Object { $_.Name -notin $excludedProperties })) 
        {
            # Lets format the AppState property to be a list in html
            $propertyValue = ''

            # Properties we will use some special formatting for to make the easier to read.
            switch ($property.Name) 
            {
                'AppState' 
                {  
                    if ([string]::IsNullOrEmpty($property.Value))
                    {
                        $propertyValue = "No app state found"
                    }
                    else 
                    {
                        $propertyValue = ConvertTo-HTMLTableFromArray -InputList ($property.Value) -ErrorAction SilentlyContinue
                        if ([string]::IsNullOrEmpty($propertyValue)) 
                        {
                            # Fallback to the original value if the conversion fails or is empty
                            $propertyValue = $property.Value
                        }
                    }                   
                }

                'DetectionRule'
                {
                    try 
                    {
                        [array]$tmpJsonString = $property.Value | ConvertFrom-Json -ErrorAction Stop
                        Foreach($item in $tmpJsonString)
                        {
                            $item.DetectionText = $item.DetectionText | ConvertFrom-Json # could be done with -depth parameter, but not in posh 5.1 
                            $propertyValue = Get-HTMLTableFromData -InputData $item.DetectionText -TableType 'ScriptBody'
                        }
                    }
                    catch 
                    {
                        # In case of an error we will just use the original string
                        $propertyValue = $property.Value
                    }                    
                }

                'RequirementRules'
                {
                    try 
                    {
                        [array]$tmpJsonString = $property.Value | ConvertFrom-Json -ErrorAction Stop
                        Foreach($item in $tmpJsonString)
                        {
                            $propertyValue += ConvertTo-HTMLTableFromArray -InputList $item
                        }
                    }
                    catch 
                    {
                        # In case of an error we will just use the original string
                        $propertyValue = $property.Value
                    }                   
                }

                'ExtendedRequirementRules'
                {
                    try 
                    {
                        [array]$tmpJsonString = $property.Value | ConvertFrom-Json -ErrorAction Stop
                        Foreach($item in $tmpJsonString)
                        {
                            $item.RequirementText = $item.RequirementText | ConvertFrom-Json # could be done with -depth parameter, but not in posh 5.1 
                            $propertyValue += Get-HTMLTableFromData -InputData $item.RequirementText -TableType 'ScriptBody'
                        }
                    }
                    catch 
                    {
                        # In case of an error we will just use the original string
                        $propertyValue = $property.Value
                    }                   
                }

                # script block detection to account for multiple properties
                { $_ -in @('InstallEx','ReturnCodes','InstallerData','RebootEx','StartDeadlineEx')}
                {     
                    $propertyValue = Get-HTMLTableFromData -InputData $property.Value 
                }

                Default 
                {
                    $propertyValue = $property.Value               
                }
                    
            }
            
            $htmlBody += "<tr><td style='font-weight: bold; width: 300px;'>$($property.Name)</td><td>$($propertyValue)</td></tr>"
        }
        $htmlBody += "</table>"
        $htmlBody += "</div>"  # Close collapsible-content
        $htmlBody += "<br>"
        $htmlBody += "</div>"  # Close collapsible-content
    }
    
    $htmlBody += "</div>"  # Close collapsible-content
    $htmlBody += "</div>"  # Close group-container
    return $htmlBody
}
#endregion