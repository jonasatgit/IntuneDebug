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
#region Test-IfStringIsValidBase64 
function Test-IfStringIsValidBase64 
{
    param([string]$Text)

    # Check format: only valid Base64 characters and optional padding
    if ($Text -notmatch '^[A-Za-z0-9+/]*={0,2}$') 
    {
        return $false
    }

    # Length must be a multiple of 4
    if ($Text.Length % 4 -ne 0) 
    {
        return $false
    }

    # Length must be at least 16 cahrs long
    if ($Text.Length -lt 16) 
    {
        return $false
    }

    try 
    {
        [Convert]::FromBase64String($Text) | Out-Null
        return $true
    } 
    catch 
    {
        return $false
    }
}
#endregion