<#
.SYNOPSIS
    Function to generate an HTML report of Intune policies.
 
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
#region Convert-IntunePoliciesToHtml
function Convert-IntunePoliciesToHtml 
{
    param 
    (
        [Parameter(Mandatory=$false)]
        [string]$OutputPath,

        [Parameter(Mandatory=$false)]
        [array]$Policies,

        [Parameter(Mandatory=$false)]
        [string]$Title = "Policy Report"
    )

    if ([string]::IsNullOrEmpty($script:MDMDiagReportPathVariable)) 
    {
        $headerSubText = "Generated locally running on $($env:COMPUTERNAME) on: 📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    else 
    {
        $headerSubText = "Generated from captured MDM Diagnostics Report on: 📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }

$htmlHeader = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>$Title</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 14px; }
        h1 { font-size: 24px; color: #2E6DA4; }
        h2 { font-size: 18px; color: #444; margin-top: 10px; }

        .toggle-button {
            background-color: #007BFF;
            color: white;
            border: none;
            padding: 5px 10px;
            margin-bottom: 10px;
            cursor: pointer;
            border-radius: 4px;
            width: 90px;           /* Fixed width for consistent size */
            text-align: center;     /* Center the text */
            box-sizing: border-box; /* Ensure padding is included in width */
        }

        .toggle-button-inner {
            background-color: #a5a5a5ff;
            color: white;
            border: none;
            padding: 5px 10px;
            margin-bottom: 5px;
            cursor: pointer;
            border-radius: 4px;
            font-size: 11px;    /* Smaller font size for inner buttons */
            width: 70px;           /* Fixed width for consistent size */
            text-align: center;     /* Center the text */
            box-sizing: border-box; /* Ensure padding is included in width */
        }

        .toggle-button-inner-script {
            background-color: #ffffffff;
            color: #333333;              /* Darker text color for visibility */
            border: 2px solid #ccc;
            padding: 3px 6px;
            margin-bottom: 5px;
            cursor: pointer;
            border-radius: 4px;
            font-size: 13px;             /* Increased font size for visibility */
            /* font-weight: bold;           Make the symbol stand out */
            /* font-family: Arial, sans-serif;  Clean, readable font */
            width: 50px;           /* Fixed width for consistent size */
            height: 30px;           /* Fixed hight for consistent size */   
            text-align: center;     /* Center the text */
            box-sizing: border-box;  /* Ensure padding is included in width */
        }

        .collapsible-content {
            display: block;
            margin-top: 10px;
        }

        .group-container {
            border: 1px solid #ccc;
            background-color: #f9f9f9;
            padding: 15px;
            margin-bottom: 30px;
            border-radius: 6px;
            box-shadow: 2px 2px 5px rgba(0,0,0,0.05);
        }

        .script-container {
            border: 1px solid #ccc;
            background-color: #f9f9f9;
            padding: 5px;
            margin-bottom: 5px;
            border-radius: 6px;
            box-shadow: 2px 2px 5px rgba(0,0,0,0.05);
        }

        .policy-area-title {
            color: #2E6DA4;
        }
        

        /* === MAIN TABLE STYLING === */
        .main-table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 20px;
            table-layout: fixed;
            border: 3px solid #ddd;
            font-size: 13px;
        }

        .main-table th,
        .main-table td {
            border: 1px solid #ddd;
            padding: 8px;
            word-wrap: break-word;
            text-align: left;
            vertical-align: top;
            font-size: 13px;
        }

        .main-table th {
            background-color: #f2f2f2;
        }

        .main-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .main-table th.resource-col,
        .main-table td.resource-col {
            width: 100px;
        }

        /* === NESTED TABLE STYLING === */
        .nested-table {
            border: none !important;
            outline: none !important;
            background-color: transparent !important;
            border-collapse: collapse;
            width: 100%;
            table-layout: fixed;
            font-size: 13px;
        }

        .nested-table th,
        .nested-table td {
            background-color: transparent !important;
            outline: none !important;
            border: none !important;
            padding: 8px;
            word-wrap: break-word;
            text-align: left;
            vertical-align: top;
        }

        .nested-table td:first-child {
            width: 200px;
        }

    

    </style>
    <script>
       
        function toggleContent(button) {
            // Find the main content section to toggle
            let content = button.parentElement.nextElementSibling;

            if (!content || !content.classList.contains('collapsible-content')) {
                const groupContainer = button.closest('.group-container');
                content = groupContainer ? groupContainer.querySelector('.collapsible-content') : null;
            }

            if (!content) return;

            const isVisible = window.getComputedStyle(content).display !== "none";
            const newDisplay = isVisible ? "none" : "block";
            const newLabel = isVisible ? "Show" : "Hide";

            // Toggle the main content
            content.style.display = newDisplay;
            button.textContent = newLabel;

            // Also toggle all nested collapsible contents and update their buttons
            const nestedContents = content.querySelectorAll('.collapsible-content');
            const nestedButtons = content.querySelectorAll('.toggle-button');

            nestedContents.forEach(nested => {
                nested.style.display = newDisplay;
            });

            nestedButtons.forEach(nestedBtn => {
                nestedBtn.textContent = newLabel;
            });
        }

 
        function toggleAll() {
            const contents = document.querySelectorAll('.collapsible-content');
            const buttons = document.querySelectorAll('.toggle-button:not(#toggleAllBtn)');
            const toggleAllBtn = document.getElementById('toggleAllBtn');
            const shouldCollapse = toggleAllBtn.textContent === 'Collapse All';

            contents.forEach((content, index) => {
                    content.style.display = shouldCollapse ? 'none' : 'block';
                if (buttons[index]) {
                buttons[index].textContent = shouldCollapse ? 'Show' : 'Hide';
            }
        });


        toggleAllBtn.textContent = shouldCollapse ? 'Expand All' : 'Collapse All';
        }


        function toggleScript(button) {
            const pre = button.parentElement.querySelector('.script-body');
            const isVisible = pre.style.display !== 'none';
            pre.style.display = isVisible ? 'none' : 'block';
            button.textContent = isVisible ? 'Show' : 'Hide';
        }


        function copyScript(button) {
            const pre = button.parentElement.querySelector('.script-body');
            const text = pre.textContent;
            navigator.clipboard.writeText(text).then(() => {
                button.textContent = '✅';
                setTimeout(() => button.textContent = 'Copy', 1500);
            });
        }

    </script>
</head>
<body>
    <h1>$Title ⚙️</h1>
    <p>$headerSubText</p>
    <p>This report contains detailed information about Intune policies applied to devices and users.</p>
    <button class='toggle-button' onclick='toggleAll()' id='toggleAllBtn'>Collapse All</button>
"@


    $htmlFooter = "</body></html>"
    $htmlBody = ""
 
    $grouped = $Policies | Group-Object -Property PolicyScope

    $htmlBody += Get-DeviceInfoHTMLTables -GroupedPolicies $grouped

    $htmlBody += Get-DeviceAndUserHTMLTables -GroupedPolicies $grouped

    $htmlBody += Get-EnterpriseApplicationHTMLTables -GroupedPolicies $grouped

    $htmlBody += Get-ResourceHTMLTables -GroupedPolicies $grouped

    $htmlBody += Get-LAPSHTMLTables -GroupedPolicies $grouped 

    $htmlBody += Get-IntuneWin32AppTables

    $htmlBody += Get-IntuneScriptPolicyTables

    $fullHtml = $htmlHeader + $htmlBody + $htmlFooter

    Set-Content -Path $OutputPath -Value $fullHtml -Encoding UTF8
}
#endregion
