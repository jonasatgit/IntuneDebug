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
#region Get-MDMFirewallSetting
Function Get-MDMFirewallSetting
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [string]$Topic,
        [Parameter(Mandatory = $true)]
        [string]$SettingName
    )

    $basePath = "HKLM:SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\Mdm"
    $topicPath = Join-Path -Path $basePath -ChildPath $Topic

    $propertyValue = $null
    if (-Not (Test-Path -Path $topicPath)) 
    {
        #Write-Error "The specified topic path does not exist: $topicPath"
        return $null
    }
    else 
    {
        try{$propertyValue = Get-ItemPropertyValue -Path $topicPath -Name $SettingName -ErrorAction SilentlyContinue }catch{}
    }

    return $propertyValue
}
#endregion