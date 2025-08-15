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
#region Get-IntuneScriptPolicies
Function Get-IntuneScriptPolicies
{

    param
    (
        [string]$LogPath
    )

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        if ([string]::IsNullOrEmpty($LogPath))
        {
            # The message does only makes sense if the script is run locally without the MDMDiagReportPath parameter
            # NOT YET
            #Write-Host "To get more Intune script details run the script with administrative permissions" -ForegroundColor Yellow 
        }
    }
    else 
    {
        if ([string]::IsNullOrEmpty($LogPath))
        {
            # Status per user ID
            # Many more entries due to older polices. Admin permissions required
            #'HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\Scripts'
        }
    }

    if ([string]::IsNullOrEmpty($LogPath))
    {
        # Default log path for intune script logs
        $LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\HealthScripts*.log"
    } 
    
    # creating hash with script id and shedule from log file
    $pattern = '\[HS\] inspect daily schedule for policy (?<policyID>.*?), (?<policyScheduleUTC>.*?), (?<policyScheduleInterval>.*?), (?<policyScheduleTime>.*?)(?=\]LOG\])'

    $scriptSSchedulePolicyResult = Get-ChildItem $LogPath | Sort-Object -Property LastWriteTime -Descending | select-string -Pattern $pattern

    $policyScheduleHash = @{}
    foreach ($scriptPolicy in $scriptSSchedulePolicyResult)
    {
        # Files sortted by LastWriteTime, so we can take the first one and have the latest policy schedule and skip the duplicates
        $policyID = $scriptPolicy.Matches.groups[1].value
        # Check if the policyID already exists in the hash
        if ($policyScheduleHash.ContainsKey($policyID)) 
        {
            # If it exists, skip to the next iteration
            continue
        }
        
        $policyScheduleUTC = ($scriptPolicy.Matches.groups[2].value) -replace 'UTC = ', ''
        $policyScheduleInterval = ($scriptPolicy.Matches.groups[3].value) -replace 'Interval = ', ''
        $policyScheduleTime = ($scriptPolicy.Matches.groups[4].value) -replace 'Time = ', ''

        # check if the policyID already exists in the hash and in the settings are identical
        $policyScheduleHash[$policyID] = [pscustomobject][ordered]@{
            #PolicyID = $policyID
            ScheduleUTC = $policyScheduleUTC
            ScheduleInterval = $policyScheduleInterval
            ScheduleTime = $policyScheduleTime
        }
    }

    # Getting script policies 
    $pattern = '\[HS\] new result = (?<policyString>\{"PolicyId.*?\})(?=\]LOG\])'
    $scriptPolicyResult = Get-ChildItem -Path $LogPath | Sort-Object -Property LastWriteTime -Descending | select-string -Pattern $pattern

    $outList = [System.Collections.Generic.List[pscustomobject]]::new()
    $policyCheckHash = @{}
    foreach ($scriptPolicy in $scriptPolicyResult)
    {
        # Files sortted by LastWriteTime, so we can take the first one and have the latest policy schedule and skip the duplicates
        $policyString = $scriptPolicy.Matches.groups[1].value

        # Convert the JSON string to a PowerShell object
        $policyData = $policyString | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($null -eq $policyData) 
        {
            Write-Verbose "Failed to convert policy data from JSON: $policyString"
            continue
        }

        if ($policyCheckHash.ContainsKey($policyData.PolicyId)) 
        {
            # If the policy ID already exists in the hash, skip to the next iteration
            continue
        }

        # Check if the policyID already exists in the hash
        if ($policyScheduleHash.ContainsKey($policyData.PolicyId)) 
        {
            # If it exists, add the schedule data to the policy data
            $policyData | Add-Member -MemberType NoteProperty -Name 'Schedule' -Value ($policyScheduleHash[$policyData.PolicyId])
        }
        else 
        {
            # If it does not exist, create a new property for the schedule with null values
            $policyData | Add-Member -MemberType NoteProperty -Name 'Schedule' -Value ([pscustomobject]@{
                #PolicyID = $null
                ScheduleUTC = $null
                ScheduleInterval = $null
                ScheduleTime = $null
            })
        }

        # Convert the RunAsAccount value to a more readable format
        Switch($policyData.RunAsAccount) 
        {
            1 { $policyData.RunAsAccount = '1 = System' }
            2 { $policyData.RunAsAccount = '2 = User' }
            Default { $policyData.RunAsAccount = "$($policyData.RunAsAccount) = Unknown" }
        }

        $policyCheckHash[$policyData.PolicyId] = $true
        # Output the policy data
        $outList.Add($policyData)
    }

    return $outList
}
#endregion