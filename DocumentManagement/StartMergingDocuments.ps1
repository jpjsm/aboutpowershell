## $baseFolder = "C:\GIT\PowerShell-Docs\reference"
## $mergeFolder = "C:\PSReferenceConversion\reference"
##  . C:\git\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\New-ReferenceUpdateMergeFile.ps1 -sourceFolder $baseFolder -comparedFolder $mergeFolder -filesToMergeList "C:\PSReferenceConversion\Merge\differences.tsv" -Verbose
. C:\git\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\Merge-DifferentVersionsOfFiles.ps1 -filesToMergeList "C:\PSReferenceConversion\Merge\differences.tsv" 
