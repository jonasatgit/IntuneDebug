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
#region Get-HTMLTableFromData
Function Get-HTMLTableFromData 
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $false)]
        [object]$InputData,
        [Parameter(Mandatory = $false)]
        [ValidateSet('ScriptBody')]
        [string]$TableType
    )

    $propertyValue = ''
    try 
    {
        # lets find out what type of data we are dealing with
        $propType = $InputData.GetType() | Select-Object -Property Name -ExpandProperty Name
    }
    catch 
    {
        $propType = 'Unknown' # Default to string if we cannot determine the type
    }

    switch ($propType) 
    {
        'PSCustomObject' 
        { 
            $propertyValue = ConvertTo-HTMLTableFromArray -InputList ($InputData) -TableType $TableType
        }

        'String'
        {
            # Some properties we should be able to convert to json and make them easier to read in that format
            try 
            {
                $propertyValue = ConvertTo-HTMLTableFromArray -InputList ($InputData | ConvertFrom-Json -ErrorAction Stop) -TableType $TableType
            }
            catch 
            {
                $propertyValue = $InputData
            }   
        }
        Default {$propertyValue = $InputData}
    }    
    
    return $propertyValue
}
#endregion