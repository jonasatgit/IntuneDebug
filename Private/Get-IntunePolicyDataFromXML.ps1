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
#region Get-IntunePolicyDataFromXML
Function Get-IntunePolicyDataFromXML
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $false)]
        [string]$MDMDiagReportPath
    )

    # If no path is provided, generate a new report
    if ([string]::IsNullOrEmpty($MDMDiagReportPath)) 
    {
        $MDMDiagFolder = "$env:PUBLIC\Documents\MDMDiagnostics\$(Get-date -Format 'yyyy-MM-dd_HH-mm-ss')"

        if (-NOT (Test-Path -Path $MDMDiagFolder)) 
        {
            New-Item -Path $MDMDiagFolder -ItemType Directory | Out-Null
        }

        $MDMDiagReportXmlPath = '{0}\MDMDiagReport.xml' -f $MDMDiagFolder

        Start-Process MdmDiagnosticsTool.exe -Wait -ArgumentList "-out `"$MDMDiagFolder`"" -NoNewWindow -ErrorAction Stop

        [xml]$xmlFile = Get-Content -Path $MDMDiagReportXmlPath -Raw -ErrorAction Stop
    }
    else 
    {
        if (-Not (Test-Path -Path $MDMDiagReportPath)) 
        {
            Write-Error "The specified MDM Diagnostics path does not exist: `"$MDMDiagReportPath`""
            return
        }

        $MDMDiagReportXmlPath = '{0}\MDMDiagReport.xml' -f $MDMDiagReportPath

        if (-Not (Test-Path -Path $MDMDiagReportXmlPath))
        {
            Write-Error "The specified MDM Diagnostics Report XML file does not exist: `"$MDMDiagReportXmlPath`""
            return
        }
        [xml]$xmlFile = Get-Content -Path $MDMDiagReportXmlPath -Raw -ErrorAction Stop
    }

    $outObj = [pscustomobject]@{
        XMlFileData = $xmlFile
        FileFullName = $MDMDiagReportXmlPath
    }
    return $outObj
}
#endregion
