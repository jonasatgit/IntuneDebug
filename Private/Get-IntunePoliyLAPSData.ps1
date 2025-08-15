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
#region Get-IntunePoliyLAPSData
Function Get-IntunePoliyLAPSData
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        $MDMData
    )

    # https://learn.microsoft.com/en-us/windows/client-management/mdm/laps-csp
    $BackupDirectoryMap = @{
        0 = "0 = Disabled (password won't be backed up)" # Default
        1 = "1 = Backup the password to Microsoft Entra ID only"
        2 = "2 = Backup the password to Active Directory only"
    }

    $PasswordComplexityMap = @{
        1 = "1 = Large letters."
        2 = "2 = Large letters + small letters."
        3 = "3 = Large letters + small letters + numbers."
        4 = "4 = Large letters + small letters + numbers + special characters." # Default
        5 = "5 = Large letters + small letters + numbers + special characters (improved readability)."
        6 = "6 = Passphrase (long words)."
        7 = "7 = Passphrase (short words)."
        8 = "8 = Passphrase (short words with unique prefixes)."
    }

    $PostAuthenticationActionMap = @{
        1  = "1 = Reset password: upon expiry of the grace period, the managed account password will be reset."
        3  = "3 = Reset the password and logoff the managed account: upon expiry of the grace period, the managed account password will be reset and any interactive logon sessions using the managed account will be terminated." # Default
        5  = "5 = Reset the password and reboot: upon expiry of the grace period, the managed account password will be reset and the managed device will be immediately rebooted."
        11 = "11 = Reset the password, logoff the managed account, and terminate any remaining processes: upon expiration of the grace period, the managed account password is reset, any interactive logon sessions using the managed account are logged off, and any remaining processes are terminated."
    }

    $AutomaticAccountManagementTargetMap = @{
        0 = "0 = Automatically manage the built-in Administrator account"
        1 = "1 = Automatically manage a new custom account"
    }

    $AutomaticAccountManagementEnableAccountMap = @{
        0 = "0 = Disable the automatically managed account"
        1 = "1 = Enable the automatically managed account"
    }

    $AutomaticAccountManagementRandomizeNameMap = @{
        0 = "0 = Don't randomize the name of the automatically managed account"
        1 = "1 = Randomize the name of the automatically managed account"
    }

    # Initialize the output object
    $lapsOutObj = [pscustomobject][ordered]@{
        PolicyScope = 'LAPS'
        BackupDirectory = $null
        PasswordAgeDays = $null
        AutomaticAccountManagementEnabled = $null
        AutomaticAccountManagementNameOrPrefix = $null
        AutomaticAccountManagementEnableAccount = $null
        AutomaticAccountManagementTarget = $null
        AutomaticAccountManagementRandomizeName = $null
        PasswordComplexity = $null
        PostAuthenticationActions = $null
        PasswordLength = $null
        PostAuthenticationResetDelay = $null
        Local_LastAccountRidUpdated = $null
        Local_DSRMMode = $null
        Local_LastManagedAccountRid = $null
        Local_LastManagedAccountNameOrPrefix = $null
        Local_LastManagedAccountRandomizeName = $null
        Local_LastPasswordUpdateTime = $null
        Local_AzurePasswordExpiryTime = $null
        Local_PostAuthResetDeadline = $null
        Local_PostAuthResetAuthenticationTime = $null
        Local_PostAuthResetAccountSid = $null
        Local_PostAuthResetRetryCount = $null
        Local_PostAuthActions = $null
    }

    $LAPSData = $MDMData.MDMEnterpriseDiagnosticsReport.LAPS

    if (-NOT [string]::IsNullOrEmpty($LAPSData.Laps_CSP_Policy)) 
    {
        $lapsOutObj.BackupDirectory = try{$BackupDirectoryMap[[int]$LAPSData.Laps_CSP_Policy.BackupDirectory]}catch {$LAPSData.Laps_CSP_Policy.BackupDirectory}
        $lapsOutObj.PasswordAgeDays = $LAPSData.Laps_CSP_Policy.PasswordAgeDays
        $lapsOutObj.AutomaticAccountManagementEnabled = if($LAPSData.Laps_CSP_Policy.AutomaticAccountManagementEnabled -eq 1){"True"}else{"False"}
        $lapsOutObj.AutomaticAccountManagementNameOrPrefix = $LAPSData.Laps_CSP_Policy.AutomaticAccountManagementNameOrPrefix
        $lapsOutObj.AutomaticAccountManagementEnableAccount = try{$AutomaticAccountManagementEnableAccountMap[[int]$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementEnableAccount]}catch {$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementEnableAccount}
        $lapsOutObj.AutomaticAccountManagementTarget = try{$AutomaticAccountManagementTargetMap[[int]$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementTarget]}catch {$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementTarget}
        $lapsOutObj.AutomaticAccountManagementRandomizeName = try{$AutomaticAccountManagementRandomizeNameMap[[int]$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementRandomizeName]}catch {$LAPSData.Laps_CSP_Policy.AutomaticAccountManagementRandomizeName}
        $lapsOutObj.PasswordComplexity = try{$PasswordComplexityMap[[int]$LAPSData.Laps_CSP_Policy.PasswordComplexity]}catch {$LAPSData.Laps_CSP_Policy.PasswordComplexity}
        $lapsOutObj.PostAuthenticationActions = try{$PostAuthenticationActionMap[[int]$LAPSData.Laps_CSP_Policy.PostAuthenticationActions]}catch {$LAPSData.Laps_CSP_Policy.PostAuthenticationActions}
        $lapsOutObj.PasswordLength = $LAPSData.Laps_CSP_Policy.PasswordLength
        $lapsOutObj.PostAuthenticationResetDelay = $LAPSData.Laps_CSP_Policy.PostAuthenticationResetDelay
       
        if (-NOT [string]::IsNullOrEmpty($LAPSData.Laps_Local_State)) 
        {
            $lapsOutObj.Local_LastAccountRidUpdated = $LAPSData.Laps_Local_State.LastAccountRidUpdated
            $lapsOutObj.Local_DSRMMode = $LAPSData.Laps_Local_State.DSRMMode
            $lapsOutObj.Local_LastManagedAccountRid = $LAPSData.Laps_Local_State.LastManagedAccountRid
            $lapsOutObj.Local_LastManagedAccountNameOrPrefix = $LAPSData.Laps_Local_State.LastManagedAccountNameOrPrefix
            $lapsOutObj.Local_LastManagedAccountRandomizeName = $LAPSData.Laps_Local_State.LastManagedAccountRandomizeName
            $lapsOutObj.Local_LastPasswordUpdateTime = try{Convert-FileTimeToDateTime -FileTime $LAPSData.Laps_Local_State.LastPasswordUpdateTime} catch {$LAPSData.Laps_Local_State.LastPasswordUpdateTime}
            $lapsOutObj.Local_AzurePasswordExpiryTime = try{Convert-FileTimeToDateTime -FileTime $LAPSData.Laps_Local_State.AzurePasswordExpiryTime} catch {$LAPSData.Laps_Local_State.AzurePasswordExpiryTime}
            $lapsOutObj.Local_PostAuthResetDeadline = try{Convert-FileTimeToDateTime -FileTime $LAPSData.Laps_Local_State.PostAuthResetDeadline} catch {$LAPSData.Laps_Local_State.PostAuthResetDeadline}
            $lapsOutObj.Local_PostAuthResetAuthenticationTime = try{Convert-FileTimeToDateTime -FileTime $LAPSData.Laps_Local_State.PostAuthResetAuthenticationTime} catch {$LAPSData.Laps_Local_State.PostAuthResetAuthenticationTime}
            $lapsOutObj.Local_PostAuthResetAccountSid = $LAPSData.Laps_Local_State.PostAuthResetAccountSid
            $lapsOutObj.Local_PostAuthResetRetryCount = $LAPSData.Laps_Local_State.PostAuthResetRetryCount
            $lapsOutObj.Local_PostAuthActions = $LAPSData.Laps_Local_State.PostAuthActions
        }

        return $lapsOutObj   
    }
}
#endregion