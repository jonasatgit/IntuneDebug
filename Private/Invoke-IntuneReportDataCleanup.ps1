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
#region Invoke-IntuneReportDataCleanup
Function Invoke-IntuneReportDataCleanup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [int]$CleanUpDays = 1
    )

    $MDMDiagFolder = "$env:PUBLIC\Documents\MDMDiagnostics"

    if (-NOT (Test-Path -Path $MDMDiagFolder)) 
    {
        return # nothing to cleanup
    }
    else 
    {
        # Get all folders with names in the format of 'yyyy-MM-dd_HH-mm-ss'
        [array]$folderList = Get-ChildItem -Path $MDMDiagFolder -Directory | Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}$' }

        # now cleanup the folders that are older than the specified number of days based on their name
        foreach ($folder in $folderList) 
        {
            # Get the folder creation time
            $folderCreationTime = [datetime]::ParseExact($folder.Name, 'yyyy-MM-dd_HH-mm-ss', $null)

            # Check if the folder is older than the specified number of days
            if ($folderCreationTime -lt (Get-Date).AddDays(-$CleanUpDays)) 
            {
                # Remove the folder and its contents
                Write-Host "Removing old policy report folder: $($folder.FullName)"
                Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
#endregion