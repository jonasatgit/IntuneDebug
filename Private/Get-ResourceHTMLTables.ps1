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
#region Get-ResourceHTMLTables
Function Get-ResourceHTMLTables
{
    param
    (
        [Parameter(Mandatory = $true)]
        [array]$GroupedPolicies
    )

    # Does not make sense when we use XML data from a different system. 
    # But does also not harm, because the report will simply not be able to match a SID to a username.
    $userInfoHash = Get-LocalUserInfo

    $resourcePolicies = $GroupedPolicies.Where({ $_.Name -eq 'Resource' }) 
    $groupedResources = $resourcePolicies.group | Group-Object -Property ResourceType, EnrollmentId 
    
    $areaTitleString = '🌐 Resources'
    $statString = "TotalResources: {0}" -f $groupedResources.Group.Count

    $htmlBody = ""
    $htmlBody += "<div class='group-container'>"
    $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>"
    $htmlBody += "<button class='toggle-button' onclick='toggleContent(this)'>Hide</button>"
    $htmlBody += "<h2>PolicyScope: <span class='policy-area-title'>$areaTitleString</span></h2>"
    $htmlBody += "</div>"
    $htmlBody += "<p style='font-size: 13px;'>$statString</p>"
    $htmlBody += "<div class='collapsible-content'>"

    foreach ($resourceEntry in ($groupedResources | Sort-Object -Property Name -Descending)) 
    {
        # Split the ResourceType, EnrollmentId from a single string
        # The format is "EResourceType, EnrollmentId"
        $tmpSplitVar = $resourceEntry.Name -split ',' # 0 = ResourceType, 1 = EnrollmentId

        $tmpResourceType = $tmpSplitVar[0].ToString().Trim()
        $tmpEnrollmentId = $tmpSplitVar[1].ToString().Trim()
        $enrollmentIdString = '{0} ➡️ {1}' -f $tmpEnrollmentId, ($resourceEntry.Group[0].ProviderID)

        $htmlBody += "<div style='display: flex; align-items: center; gap: 10px;'>" 
        $htmlBody += "<button class='toggle-button-inner' onclick='toggleContent(this)'>Hide</button>" 
        $htmlBody += "<h2 class='policy-area-title'>ResourceType: $($tmpResourceType)</h2>"
        $htmlBody += "</div>" 
        $htmlBody += "<div class='collapsible-content'>" 
        $htmlBody += "<table class='main-table'>"
        #$htmlBody += "<tr><td style='font-weight: bold;'>EnrollmentId</td><td colspan='5'>$($enrollmentIdString)</td></tr>"

        if ($tmpResourceType -eq 'RootCATrustedCertificates')
        {
            $htmlBody += "<tr><td style='font-weight: bold;'>EnrollmentId</td><td colspan='5'>$($enrollmentIdString)</td></tr>"
            $htmlBody += "<tr style='border-top: 3px solid #ddd;'><th style='font-weight: bold;'>ResourceTarget ⚙️</th><th>CertStore</th><th>Thumbprint</th><th>IssuedTo</th><th>Issuer</th><th>ExpiresIn</th></tr>"
        }
        elseif ($tmpResourceType -eq 'Firewall') 
        {
            $htmlBody += "<tr><td style='font-weight: bold;'>EnrollmentId</td><td colspan='3'>$($enrollmentIdString)</td></tr>"
            $htmlBody += "<tr style='border-top: 3px solid #ddd;'><th style='font-weight: bold;'>ResourceTarget ⚙️</th><th>Resource</th><th>Name</th><th>Value</th></tr>"
        }
        else 
        {
            $htmlBody += "<tr><td style='font-weight: bold; width: 500px;'>EnrollmentId</td><td>$($enrollmentIdString)</td></tr>"
            $htmlBody += "<tr style='border-top: 3px solid #ddd;'><th style='font-weight: bold; width: 500px;'>ResourceTarget ⚙️</th><th>Resource</th></tr>"
        }

        foreach ($resource in $resourceEntry.Group) 
        {
            
            if ($resource.ResourceTarget -eq 'Device') 
            {
                $resourceTargetString = '💻 Device'
            } 
            else 
            {
                $userName = $userInfoHash[$resource.ResourceTarget]
                if ([string]::IsNullOrEmpty($userName))
                {
                    $resourceTargetString = '👤 {0} - Unknown' -f ($resource.ResourceTarget)
                }
                else
                {
                    $resourceTargetString = '👤 {0} - {1}' -f ($resource.ResourceTarget), $userName
                }
            }

            # If the resource is a certificate, we need to display the certificate details
            if ($tmpResourceType -eq 'RootCATrustedCertificates')
            {
                # If the resource is a certificate, we can display the certificate details
                $tmpExpireDays = $resource.ResourceData.ExpireDays
                try 
                {
                    if (([int]$resource.ResourceData.ExpireDays -le 0) -and -not ([string]::IsNullOrEmpty($resource.ResourceData.ExpireDays)))
                    {
                        $tmpExpireDays = '⚠️ {0}' -f $resource.ResourceData.ExpireDays   
                    }
                }
                catch {}

                $htmlBody += "<tr><td class='setting-col'>$($resourceTargetString)</td>"
                $htmlBody += "<td>$($resource.ResourceData.CertStore)</td>"
                $htmlBody += "<td>$($resource.ResourceData.Thumbprint)</td>"
                $htmlBody += "<td>$($resource.ResourceData.IssuedTo)</td>"
                $htmlBody += "<td>$($resource.ResourceData.Issuer)</td>"
                $htmlBody += "<td>$($tmpExpireDays)</td>"
                $htmlBody += "</tr>"

            }
            elseif ($tmpResourceType -eq 'Firewall') 
            {
                # If the resource is a firewall setting, we can try to display the firewall setting details
                $tmpName = ''
                $tmpFirewallSetting = ''

                $tmpSplit = $resource.ResourceName -split '\/'
                try 
                {
                    $tmpFirewallSetting = Get-MDMFirewallSetting -Topic ($tmpSplit[-2]) -SettingName ($tmpSplit[-1])
                }
                catch 
                {
                    $tmpFirewallSetting = $resource.ResourceName
                }
                 
                if ($resource.ResourceName -match 'FirewallRules')
                {
                    $tmpName = $tmpFirewallSetting -replace '.*\|Name=([^|]+)\|.*', '$1'
                }
                else 
                {
                    $tmpName = ($tmpSplit[-1])
                }

                $tmpResourceName = '{0}\{1}' -f ($tmpSplit[-2]), ($tmpSplit[-1])

                $htmlBody += "<tr><td class='setting-col'>$($resourceTargetString)</td>"
                $htmlBody += "<td>$($tmpResourceName)</td>"
                $htmlBody += "<td>$($tmpName)</td>"
                $htmlBody += "<td>$($tmpFirewallSetting)</td>"
                $htmlBody += "</tr>"
            }
            else 
            {
                # If the is an Office installation, we can get the install parameters from registry to display them in the report
                $tmpResourceName = $resource.ResourceName
                
                if ($tmpResourceName -match 'MSFT/Office/Installation')
                {
                    $officeResult = try{Get-IntuneOfficeInstallParams -ID ($tmpResourceName | Split-Path -Leaf)}catch{}
                    if ($officeResult)
                    {
                        # Escape the resource name to prevent the resource name from breaking our HTML
                        $officeResultEscaped = Invoke-EscapeHtmlText -Text ($officeResult)   
                        # We want to display the resource name and the office result in a single cell
                        $resourceName = '{0}<br><br>{1}' -f $tmpResourceName, $officeResultEscaped
                    }
                    else 
                    {
                        # Escape the resource name to prevent the resource name from breaking our HTML
                        $resourceName = Invoke-EscapeHtmlText -Text ($tmpResourceName)
                    }
                }
                else
                {
                    # Escape the resource name to prevent the resource name from breaking our HTML
                    $resourceName = Invoke-EscapeHtmlText -Text ($tmpResourceName)
                }

                $htmlBody += "<tr><td class='setting-col'>$($resourceTargetString)</td><td>$resourceName</td></tr>"
            }
        }
        
        $htmlBody += "</table>"
        $htmlBody += "</div>"
        $htmlBody += "<br>"

    }
    $htmlBody += "</div>"  # Close collapsible-content
    $htmlBody += "</div>"  # Close group-container
    return $htmlBody
}
#endregion