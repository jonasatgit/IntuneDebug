<#
.SYNOPSIS
    This function will retrieve Passport for Work related settings from the registry.
 
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

function Get-PassportForWorkSettings
{
    param
    (
        [string]$ResourceName
    )

    $basePath = "HKLM:\SOFTWARE\Microsoft\Policies\PassportForWork"

    $passportForWorkSettings = Get-ChildItem $basePath -Recurse -ErrorAction SilentlyContinue

    $outList = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($setting in $passportForWorkSettings) 
    {
        $shortPathSplit = ($setting.PSParentPath -split 'SOFTWARE\\Microsoft\\Policies')
        $shortPath = '{0}\{1}' -f ($shortPathSplit[1] -replace '^\\'), $setting.PSChildName

        $valueNames = $setting.GetValueNames()

        foreach($valueName in $valueNames)
        {
            $tmpObj = [ordered]@{
                Path = '{0}\{1}' -f $shortPath, $valueName
                Value = $setting.GetValue($valueName)
            }
            $outList.Add([PSCustomObject]$tmpObj)
        }
    }

    if($ResourceName)
    {
        $resourceNameSplit = $ResourceName -split '\/MSFT\/'
        $searchString = $resourceNameSplit[1] -replace '/', '\'
        [array]$returnList = $outList | Where-Object { $_.Path -like "$($searchString)*" }
        return $returnList
    }
    else 
    {
        return $outList  
    } 
}

