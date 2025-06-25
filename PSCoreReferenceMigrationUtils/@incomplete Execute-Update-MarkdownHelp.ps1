
<#
$module = 'Microsoft.PowerShell.Utility'
$folder = "c:\tmp\reference\test\"
$markdownfile = "Add-Member.md"

$logfileName = "c:\tmp\reference\$markdownfile-Update-MarkdownHelp-$yyyymm.log"



if($module -ine 'Microsoft.PowerShell.Core'){
    Import-Module -Name $module     
}
$results = Update-MarkdownHelp -Path "$folder$markdownfile" -LogPath $logfileName  -Verbose 
$results

#>



<#
#>
[string]$referenceFolder = "C:\PSReferenceMigration\v5.0"
[string]$logfilesFolder = "C:\PSReferenceMigration\logs\v5.0"

$yyyymm = [System.DateTime]::Now.ToString("yyyy-MM-dd HHmmss")
[string]$executionOutputLog = "$yyyymm 01 output.log"
[string]$executionErrorLog = "$yyyymm 02 error.log"
[string]$executionWarningLog = "$yyyymm 03 warning.log"
[string]$executionVerboseLog = "$yyyymm 04 verbose.log"

[string[]]$moduleNames = @()
$moduleNames = Get-ChildItem -Path $referenceFolder | Where-Object { $_.PSIsContainer } | ForEach-Object { $_.Name }
$moduleNames | ForEach-Object {

    if($_ -ine 'Microsoft.PowerShell.Core'){
        Import-Module -Name $_ -Verbose     
    }
} 1>$executionOutputLog 2>$executionErrorLog 3>$executionWarningLog 4>$executionVerboseLog

Get-ChildItem -Path $referenceFolder -Filter "*.md" -Recurse | `
    ForEach-Object {
        [string]$filepath = $_.FullName
        [string]$mdfilename = $_.BaseName
        [string]$relpath = $filepath.Substring($referenceFolder.Length+1)
        [string]$module = $relpath.Split('\')[0]
        $logfilename = Join-Path -Path $logfilesFolder -ChildPath "$module\$yyyymm\$mdfilename.log"
        Update-MarkdownHelp -Path "$filepath" -LogPath $logfilename  -Verbose
    } 1>$executionOutputLog 2>$executionErrorLog 3>$executionWarningLog 4>$executionVerboseLog
