
<#
.SYNOPSIS
    This function attempts to parse a string into a DateTime object using a set of known formats.
 
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
#region Get-ValidDateTime
function Get-ValidDateTime
{
    param 
    (
        [string]$DateTimeString
    )

    $knownFormats = @(
        'M-d-yyyy HH:mm:ss.fffffff',
        'M-dd-yyyy HH:mm:ss.fffffff',
        'MM-d-yyyy HH:mm:ss.fffffff',
        'MM-dd-yyyy HH:mm:ss.fffffff',
        'yyyy-MM-dd HH:mm:ss.fffffff',
        'dd.MM.yyyy HH:mm:ss.fffffff'
        'M-d-yyyy HH:mm:ss',
        'M-dd-yyyy HH:mm:ss',
        'MM-d-yyyy HH:mm:ss',
        'MM-dd-yyyy HH:mm:ss',
        'yyyy-MM-dd HH:mm:ss',
        'dd.MM.yyyy HH:mm:ss'
    )

    foreach ($format in $knownFormats) 
    {
        try 
        {
            return [datetime]::ParseExact($DateTimeString, $format, $null)
        } 
        catch 
        {
            continue
        }
    }
}
#endregion