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
#region Get-MSIProductCodesWithNames
function Get-MSIProductCodesWithNames 
{
    $results = @()

    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $registryPaths) 
    {
        if (Test-Path $path) {
            Get-ChildItem -Path $path | ForEach-Object {
                $key = $_
                $productCode = $key.PSChildName

                if ($productCode -match '^\{[0-9A-F\-]{36}\}$') 
                {
                    $props = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
                    $displayName = $props.DisplayName

                    $results += [PSCustomObject]@{
                        ProductCode = $productCode
                        Name        = $displayName
                    }

                }
            }
        }
    }
    return $results
}
#endregion