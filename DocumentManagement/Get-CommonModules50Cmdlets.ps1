$commonModules50 = @(
    'ISE',
    'Microsoft.PowerShell.Archive',
    'Microsoft.PowerShell.Core',
    'Microsoft.PowerShell.Diagnostics',
    'Microsoft.PowerShell.Host',
    'Microsoft.PowerShell.LocalAccounts',
    'Microsoft.PowerShell.Management',
    'Microsoft.PowerShell.ODataUtils',
    'Microsoft.PowerShell.Security',
    'Microsoft.PowerShell.Utility',
    'Microsoft.WsMan.Management',
    'PackageManagement',
    'PowershellGet',
    'PSReadline',
    'PSScheduledJob',
    'PSScriptAnalyzer',
    'PSWorkflow',
    'PSWorkflowUtility')

[string] $psversion = $PSVersionTable["PSVersion"].ToString()
[string] $moduleListingFormat = "{0,-10} {1,-50} {2}"
[string] $moduleCsvFormat = "{0},{1},{2},{3},{4}"
$moduleData = @()
Get-Command -Module $commonModules50 | 
    Group-Object -Property Source | 
    Sort-Object -Property Name |
    ForEach-Object {
        $moduleName = $_.Name
        Write-Output "==========   PowerShell version: $psversion   =========="
        Write-Output ""
        Write-Output "Module: $moduleName"
        Write-Output ""
        Write-Output ""
        Write-Output ($moduleListingFormat -f "Type","Cmdlet","version")
        Write-Output ($moduleListingFormat -f "----","------","-------")
        $_.Group |
            Sort-Object -Property CommandType, Name | 
            ForEach-Object { 
                Write-Output ($moduleListingFormat -f ($_.CommandType),($_.Name),($_.Version))
                $moduleData += $moduleCsvFormat -f $_.Name,$psversion.Substring(0,3),$moduleName,$_.CommandType,$_.Version
                }
        Write-Output ""
        Write-Output ""
    }

[System.IO.File]::WriteAllLines("c:\tmp\CommonModules50.csv",$moduleData)