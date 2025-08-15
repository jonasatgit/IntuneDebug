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
#region Convert-FileTimeToDateTime 
function Convert-FileTimeToDateTime 
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [UInt64]$FileTime
    )

    $seconds = $FileTime / 10000000

    # FILETIME epoch starts at January 1, 1601 (UTC)
    # PowerShell 5.1 doesn't support -AsUTC, so use DateTime with Kind set to UTC
    $epoch = [DateTime]::SpecifyKind([DateTime]::Parse("1601-01-01T00:00:00"), [DateTimeKind]::Utc)

    # Add the seconds to the epoch
    $datetime = $epoch.AddSeconds($seconds)

    # Format the output
    return $datetime.ToString("yyyy-MM-dd HH:mm:ss")
}
#endregion
