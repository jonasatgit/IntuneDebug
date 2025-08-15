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
#region Get-IntuneWin32AppPolicies
function Get-IntuneWin32AppPolicies
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $false)]
        [string]$LogPath
    )

    $statusList = [System.Collections.Generic.List[pscustomobject]]::new()

    # check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        if ([string]::IsNullOrEmpty($script:MDMDiagReportPathVariable))
        {
            # The message does only makes sense if the script is run locally without the MDMDiagReportPath parameter
            Write-Host "To get a more detailed Win32App report run the command with administrative permissions" -ForegroundColor Yellow
        }
    }
    else
    {
        [array]$win32AppStatusServiceReports = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\StatusServiceReports"
        
        foreach ($report in $win32AppStatusServiceReports)
        {

            $identityID = $report.Name | Split-Path -Leaf -ErrorAction SilentlyContinue

            $assignedTo = if ($identityID -eq '00000000-0000-0000-0000-000000000000'){'💻 Device'}else{'👤 {0}' -f $identityID.ToString()}
            [array]$reportData = Get-ChildItem -Path $report.PSPath

            foreach ($dataItem in $reportData)
            {
                # adding some symbols
                $tmpApplicabilityCode = $dataItem.GetValue("ApplicabilityCode")
                if ($tmpApplicabilityCode -eq 'Applicable'){$tmpApplicabilityCode = '✅ Applicable'}else{$tmpApplicabilityCode = '❌ {0}' -f $tmpApplicabilityCode}
                
                $tmpStatus = $dataItem.GetValue("Status")
                if ($tmpStatus -eq 'Installed'){$tmpStatus = '✅ Installed'}else{$tmpStatus = '❌ {0}' -f $tmpStatus}

                $tmpObj = [pscustomobject][ordered]@{
                    #AssignedTo         = $assignedTo
                    Identity            = $assignedTo
                    AppId              = $dataItem.GetValue("AppId")
                    ApplicabilityCode  = $tmpApplicabilityCode
                    ApplicabilityCode2 = $dataItem.GetValue("ApplicabilityCode2")
                    CustomError        = $dataItem.GetValue("CustomError")
                    Required           = $dataItem.GetValue("Required")
                    Status             = $tmpStatus
                    Status2            = $dataItem.GetValue("Status2")
                    ErrorCode          = $dataItem.GetValue("ErrorCode")
                }

                $statusList.Add($tmpObj)            
            }
        }
    }
    

    if ([string]::IsNullOrEmpty($LogPath))
    {
        # Default log path for Win32 App Management logs
        $LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AppWorkload*.log"
    }       

    $logFiles = Get-ChildItem -Path $LogPath | Sort-Object -Property LastWriteTime -Descending

    # Corrected regex pattern for extracting the policy JSON
    $pattern = '<!\[LOG\[Get policies = (?<policy>\[\{.*?\}\])\]LOG\]!>'

    # Get all policies with regex pattern filter
    $lines = $logFiles | Select-String -Pattern $pattern

    if ($lines) 
    {
        $appPolicyList = [System.Collections.Generic.List[PSCustomObject]]::new()
        $boolErrorHappened = $false
        foreach ($line in $lines) 
        {
            # Extract date and time
            $Matches = $null
            if ($line.Line -match 'time="(?<time>.*?)" date="(?<date>.*?)"') 
            {
                $dateTimeString = '{0} {1}' -f ($Matches['date']), ($Matches['time'])
                # Parse the date and time to a DateTime object
                $dateTime = $null
                $dateTime = Get-ValidDateTime -DateTimeString $dateTimeString

                # If parsing fails, output a warning once. Every line might fail and we dont want 200 errors visible
                if ((-NOT $dateTime) -and (-not $boolErrorHappened))
                {
                    Write-Warning "Failed to parse date and time from file: $($line.Filename) and line: $($line.Line)"
                    $boolErrorHappened = $true
                    continue
                }            
            }

            # Extract and convert the policy JSON
            $Matches = $null
            if ($line.Line -match $pattern) 
            {
                $policyJson = $Matches['policy']
                try 
                {
                    $policyObject = $policyJson | ConvertFrom-Json -ErrorAction Stop

                    # add property
                    foreach ($app in $policyObject)
                    {
                        # Set to default value
                        $app | Add-Member -MemberType NoteProperty -Name 'AppState' -Value @()       
                    }

                    $appPolicyList.Add([PSCustomObject][ordered]@{
                        DateTime = $dateTime
                        PolicyCount = $policyObject.Count
                        Policy   = $policyObject
                    })
                } 
                catch 
                {
                    Write-Warning "Failed to parse JSON from line: $($line.Filename). Error: $_"
                }
            }
        }

        # Output the parsed policies
        $appList = $appPolicyList | Sort-Object -Property DateTime -Descending | Select-Object -First 1
    }


    # Now we have the appList with the latest policies, lets add the status information
    if ($statusList.count -gt 0)
    {
        foreach ($app in $appList.Policy)
        {
            [array]$appState = $statusList | Where-Object -Property 'AppID' -EQ ($app.Id) | Select-Object Identity, ApplicabilityCode, Required, Status, ErrorCode
            if ($appState.count -gt 0)
            {
                $app.AppState = $appState
            }
        }
    }

    return ($appList.Policy | Sort-Object -Property Name)
}
#endregion