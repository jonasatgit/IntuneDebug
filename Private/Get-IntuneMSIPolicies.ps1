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
#region Get-IntuneMSIPolicies
Function Get-IntuneMSIPolicies
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        $MDMData
    )


    $StatusCodes = @{
        10 = "⚙️ Initialized"
        20 = "⬇️ Download In Progress"
        25 = "🔁 Pending Download Retry"
        30 = "❌ Download Failed"
        40 = "✅ Download Completed"
        48 = "🧑‍💻 Pending User Session"
        50 = "⚙️ Enforcement In Progress"
        55 = "🔁 Pending Enforcement Retry"
        60 = "🚫 Enforcement Failed"
        70 = "✅ Enforcement Completed"
    }

    $outList = [System.Collections.Generic.List[pscustomobject]]::new()
    Foreach ($user in $MDMData.MDMEnterpriseDiagnosticsReport.EnterpriseDesktopAppManagementinfo.MsiInstallations.TargetedUser)
    {
        $assignmentIdentity = if($user.UserSID -eq 'S-0-0-00-0000000000-0000000000-000000000-000'){'Device'}else{$user.UserSID}
        
        foreach ($package in $user.Package)
        {
            foreach ($packageDetail in $package.Details)
            {  

                if ([string]::IsNullOrEmpty($packageDetail.CurrentDownloadUrl))
                {
                    $possibleAppName = 'Unknown'    
                }
                else 
                {
                    $possibleAppName = ($packageDetail.CurrentDownloadUrl | Split-Path -Leaf -ErrorAction SilentlyContinue)
                }

                # A specifc order helps to keep the output consistent and easier to find information
                $outObj = [PSCustomObject][ordered]@{
                    PossibleAppName = $possibleAppName
                    AssignmentIdentity = $assignmentIdentity
                    Status = $packageDetail.Status
                    LastError = $packageDetail.LastError
                    ProductVersion = $packageDetail.ProductVersion
                    ProductCode = $packageDetail.ProductCode
                    CreationTime = $packageDetail.CreationTime
                    EnforcementStartTime = $packageDetail.EnforcementStartTime
                    CurrentDownloadUrl = $packageDetail.CurrentDownloadUrl
                    CommandLine = $packageDetail.CommandLine
                    DownloadLocation = $packageDetail.DownloadLocation
                    DownloadInstall = $packageDetail.DownloadInstall
                    EnforcementRetryCount = $packageDetail.EnforcementRetryCount
                    EnforcementRetryIndex = $packageDetail.EnforcementRetryIndex
                    EnforcementRetryInterval = $packageDetail.EnforcementRetryInterval
                    EnforcementTimeout = $packageDetail.EnforcementTimeout
                    FileHash = $packageDetail.FileHash
                    LocURI = $packageDetail.LocURI
                    ActionType = $packageDetail.ActionType
                    AssignmentType = $packageDetail.AssignmentType
                    BITSJobId = $packageDetail.BITSJobId
                    JobStatusReport = $packageDetail.JobStatusReport
                    ServerAccountID = $packageDetail.ServerAccountID
                    PackageId = $packageDetail.PackageId
                    PackageType = 'MSI'
                    PolicyScope = 'EnterpriseDesktopAppManagement'                    
                }

                try 
                {
                    $tmpCreationTime = Convert-FileTimeToDateTime -FileTime $outObj.CreationTime   
                    $outObj.CreationTime = $tmpCreationTime
                }
                catch {
                    Write-Host "Failed to convert CreationTime for package: $($outObj.PackageId). Error: $_"
                }

                try 
                {
                    $tmpEnforcementStartTime = Convert-FileTimeToDateTime -FileTime $outObj.EnforcementStartTime   
                    $outObj.EnforcementStartTime = $tmpEnforcementStartTime
                }
                catch {
                    Write-Host "Failed to convert EnforcementStartTime for package: $($outObj.PackageId). Error: $_"
                }
                # Convert the status code to a human-readable string
                try
                {
                    $tmpStatus = $StatusCodes[[int]($outObj.Status)]
                    $outObj.Status = $tmpStatus
                }catch{}
                 

                $outList.Add($outObj)
            }
        }      
    }

    $outListSorted = $outList | Sort-Object -Property PossibleAppName, CreationTime -Descending

    return $outListSorted
}
#endregion