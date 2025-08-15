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
#region ConvertTo-HTMLTableFromArray
Function ConvertTo-HTMLTableFromArray 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$InputList,
        [Parameter(Mandatory = $false)]
        [string]$TableType 
    )


    $htmlOutput = ""

    for ($i = 0; $i -lt $InputList.Count; $i++) 
    {
        $item = $InputList[$i]
        $htmlOutput += "<table class='nested-table'>"

        foreach ($prop in $item.PSObject.Properties) 
        {

            if ($TableType -eq 'ScriptBody' -and $prop.Name -eq 'ScriptBody') 
            {
                # If the property is ScriptBody, decode it and display it in a <pre> tag
                # This is to handle the case where the script body is base64 encoded
                # and we want to display it as text in the HTML report

                $htmlOutput += "<tr>"
                $htmlOutput += "<td colspan='2'>$($prop.Name)</td>"
                $htmlOutput += "</tr>"

                try 
                {
                    $htmlOutput += "<tr>"
                    $decodedBytes = [System.Convert]::FromBase64String($InputList.ScriptBody)
                    $decodedString = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
                  
                    $htmlOutput += "<td colspan='2'>"
                    $htmlOutput += "   <div class='script-container'>"
                    $htmlOutput += "        <button class='toggle-button-inner-script' onclick='toggleScript(this)'>Hide</button>"
                    $htmlOutput += "        <button class='toggle-button-inner-script' onclick='copyScript(this)'>Copy</button>"
                    $htmlOutput += "        <pre class='script-body'>$decodedString</pre>"
                    $htmlOutput += "    </div>"
                    $htmlOutput += "</td>"
                    $htmlOutput += "<tr>"
                } 
                catch 
                {
                    $htmlOutput += "<td>$(Invoke-EscapeHtmlText -Text ($prop.Value.ToString()))</td>"
                }                
            } 
            else 
            {
                $htmlOutput += "<tr>"
                $htmlOutput += "<td>$($prop.Name)</td>"

                if ($prop.Value -is [System.Management.Automation.PSObject] -or $prop.Value -is [hashtable]) 
                {
                    # Recursively call the same function for nested objects
                    $nestedHtml = ConvertTo-HTMLTableFromArray -InputList @($prop.Value)
                    $htmlOutput += "<td>$nestedHtml</td>"
                } 
                else 
                {
                    $htmlOutput += "<td>$($prop.Value)</td>"
                }

                $htmlOutput += "</tr>"
            }
        }

        $htmlOutput += "</table>"

        # Add <hr> only if this is not the last item
        if ($i -lt $InputList.Count - 1) 
        {
            $htmlOutput += "<hr style='border: 0; border-top: 1px solid #ccc; margin: 20px 0;'>"
        }
    }

    return $htmlOutput
}
#endregion