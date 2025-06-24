[string]$documentsfolder = "C:\GIT\PowerShell-Docs\scripting"

$initialWarningPreference = $WarningPreference
$initialErrorActionPreference = $ErrorActionPreference

$mdLinkPattern = "\[([^!].+?)\]\((.+?(?>\(v=.+\))*[^)]+?)\)"

$brokenlinks = @() ## an array of hashtable items
$linksDictionary = @{}

$linkreferences = get-childitem -Path $documentsfolder -Filter "*.md" -recurse |`
    Where-Object { $_.Directory.FullName -notlike "*.ignore*" } |`
    ForEach-Object { 
        if(-not $linksDictionary.ContainsKey( $_.Name)) {$linksDictionary.Add($_.Name, @())}
        $linksDictionary[$_.Name] += $_.FullName
        $_
    } |`
    Select-String $mdLinkPattern -AllMatches |`
    ForEach-Object { $_.Matches | ForEach-Object { $_.Groups[2].Value } }

<#
    ForEach-Object { 
        $currentPath = $_.Path;
        $currentLineNumber = $_.linenumber 
        $_.captures | ForEach-Object { @{link=$_.groups[3].value;path=$currentPath;linenumber=$currentLineNumber }} }
#>

$uniqueLinksDictionary = @{}
$linksDictionary.GetEnumerator() | ? { $_.Value.Length -eq 1} | % { $uniqueLinksDictionary.Add($_.Key, $_.Value[0]) }
