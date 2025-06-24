$sourceDocs = "C:\WpsHelpServer\Core\2016-10-05 1204\Out"
$includePattern = "[!INCLUDE["

$issues = @{}
$issues.Add("Includes", @())
$issues.Add("ZeroGuid", @())

Get-ChildItem -Path $sourceDocs -Filter "*.md" -Recurse |
    Select-String -SimpleMatch $includePattern -AllMatches |
    Select-Object -Property Path,LineNumber |
    ForEach-Object { $issues["Includes"] += ("{0,6} {1}" -f ($_.LineNumber),($_.Path)) }

$zeroGuidPattern = "\[([- A-Za-z0-9]+)\]\((00000000-0000-0000-0000-000000000000)\)"
Get-ChildItem -Path $sourceDocs -Filter "*.md" -Recurse |
    Select-String -Pattern $zeroGuidPattern -AllMatches |
    Select-Object -Property Path,LineNumber |
    ForEach-Object { $issues["ZeroGuid"] += ("{0,6} {1}" -f ($_.LineNumber),($_.Path)) }

$issues["Includes"].Length
$issues["ZeroGuid"].Length

$issues["ZeroGuid"]