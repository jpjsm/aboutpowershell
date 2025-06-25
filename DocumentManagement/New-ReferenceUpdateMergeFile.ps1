<#
    [string]$sourceFolder = "C:\GIT\PowerShell-Docs\reference"
    [string]$comparedFolder = "C:\PSReferenceConversion\reference"
    [string]$filesToMergeList = "C:\PSReferenceConversion\Merge\differences.tsv"

    . C:\GIT\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\New-ReferenceUpdateMergeFile.ps1 -sourceFolder $sourceFolder -comparedFolder $comparedFolder -filesToMergeList $filesToMergeList
#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$sourceFolder ,
    [parameter(Mandatory=$true)][string]$comparedFolder,
    [parameter(Mandatory=$true)][string]$filesToMergeList
)

. C:\GIT\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\Get-MergeFolderDifferences.ps1 -sourceFolder $sourceFolder -comparedFolder $comparedFolder

[string]$fileContentPattern = "{0}`t{1}`t{2}`t{3}`t{4}" ## $differentContentPath,$sourceFolder,$comparedFolder,$status,$lastUpdate
[string]$status = "Pending"
[string]$lastUpdate = ""

[string[]]$fileContent = @()

$differentContentPaths |
    ForEach-Object {
        Write-Progress "Reading »$_« ..."

        $differentContentPath = $_
        $fileContent += ($fileContentPattern -f $differentContentPath,$sourceFolder,$comparedFolder,$status,$lastUpdate)
    }

[System.IO.File]::WriteAllLines($filesToMergeList, $fileContent, [System.Text.Encoding]::Unicode)
Write-Verbose "Done!"