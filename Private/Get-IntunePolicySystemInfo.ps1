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
#region Get-IntunePolicySystemInfo
# Extract system information from the MDM Diagnostics Report
Function Get-IntunePolicySystemInfo
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [string]$HtmlReportPath
    )

    if (-not (Test-Path -Path $HtmlReportPath)) 
    {
        # Lets thest for a different file name
        # This might be the case if the report was generated with the settings app or the MDM Diagnostics Tool with differnt parameters
        # MDMDiagHTMLReport.html
        $HtmlReportPath = $HtmlReportPath -replace 'MDMDiagReport\.html', 'MDMDiagHTMLReport.html'
    }

    $htmlFile = Get-Content -Path $HtmlReportPath -Raw -ErrorAction SilentlyContinue

    $tablePattern = '<table[^>]*id="(?:DeviceInfoTable|ConnectionInfoTable)"[^>]*>(.*?)<\/table>'
    $tableMatches = [regex]::Matches($htmlFile, $tablePattern, 'Singleline')

    $properties = @{} 
    
    $outObj = [pscustomobject][ordered]@{
                    DeviceName = $null
                    Organization = $null
                    Edition = $null
                    OSBuild = $null
                    Processor = $null
                    #InstalledRAM = $null
                    SystemType = $null
                    #ManagedBy = $null
                    LastSync = $null
                    ManagementServerAddress = $null
                    ExchangeID = $null
                    ActiveSID = $null
                    ActiveAccount = $null
                    UserToken = $null
                    PolicyScope = 'DeviceInfo'
                }

    foreach($tableMatch in $tableMatches)
    {
        $rowPattern = '"LabelColumn">(?<Label>.*?)</td><td.*?>(?<Value>.*?)</td>'
        $valueResults = [regex]::Matches($tableMatch, $rowPattern)

        
        foreach($item in $valueResults)
        {
            $labelObj = $item.Groups | Where-Object -Property Name -eq 'Label'
            $valueObj = $item.Groups | Where-Object -Property Name -eq 'Value'

            $properties[$labelObj.Value] = $valueObj.Value
        }
    }

    $tmpObj = [PSCustomObject]$properties
    try 
    {
        $outObj.DeviceName = $tmpObj.'PC name'
        $outObj.Organization = $tmpObj.'Organization'
        $outObj.Edition = $tmpObj.'Edition'
        $outObj.OSBuild = $tmpObj.'OS Build'
        $outObj.Processor = $tmpObj.'Processor'
        #$outObj.InstalledRAM = $tmpObj.'Installed RAM'
        $outObj.SystemType = $tmpObj.'System Type'
        #$outObj.ManagedBy = $tmpObj.'Managed By'
        $outObj.LastSync = $tmpObj.'Last Sync'
        $outObj.ManagementServerAddress = $tmpObj.'Management Server Address'
        $outObj.ExchangeID = $tmpObj.'Exchange ID'
        $outObj.ActiveSID = $tmpObj.'Active SID'
        $outObj.ActiveAccount = $tmpObj.'Active Account'
        $outObj.UserToken = $tmpObj.'User Token'

        if ($outObj.OSBuild -gt 10.0.19045) 
        {
            $outObj.Edition = $outObj.Edition -replace 'Windows 10', 'Windows 11'
        }

        # lets remove the word unknown from the systemtype if it is present
        $outObj.SystemType = ($outObj.SystemType -replace 'Unknown', '') -replace '^\s+',''     
    }
    catch {}

    return $outObj
}
#endregion