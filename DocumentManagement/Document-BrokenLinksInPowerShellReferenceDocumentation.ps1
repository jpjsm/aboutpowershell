
$timestamp = [datetime]::Now.ToString("yyyy-MM-dd.HH.mm.ss")

$OutputFolder = "C:\tmp\DocumentBrokenLinks"
## $ReferenceRoot = "C:\Repos\GitHub\msft\PowerShell-Docs\reference"
$ReferenceRoot = "C:\Repos\GitHub\msft\PowerShell-Docs\reference"

$DocSets = @("docs-conceptual") ##@("3.0", "4.0", "5.0", "5.1", "6", "docs-conceptual") 
$BrokenLinksCollection = @{}

$DocSets | ForEach-Object {
    $DocSetPath = Join-Path -Path $ReferenceRoot -ChildPath $_
    Write-Progress "Processing $DocSetPath ..."
    $BrokenLinksCollection[$_] = Get-BrokenReferencesInMDCollection -CollectionFolder $DocSetPath ##| Restore-BrokenReferencesInMDCollection -CollectionFolder $DocSetPath -UseTextForEmptyLinks 
    $brokenlinkcount = $BrokenLinksCollection[$_].Count
    Write-Output ("{0,-20}`t{1,6:N0}" -f $_,$brokenlinkcount)
}

$DocSets | ForEach-Object {
    $lines = @("DocumentPath`tLineNumber`tOriginalReference`tNewReference`tReferenceStatus")
    $BrokenLinksCollection[$_] | 
        ForEach-Object {
            $lines += ("{0}`t{1}`t{2}`t[{3}]({4})`t{5}" -f $_.DocumentPath, $_.LineNumber, $_.OriginalReference, $_.Text, $_.Link, $_.ReferenceStatus)
        }
    $OutputFile = join-path -Path $OutputFolder -ChildPath ("$timestamp BrokenLinks_Fixed_$_.txt")
    [System.IO.File]::WriteAllLines($OutputFile, $lines)
}