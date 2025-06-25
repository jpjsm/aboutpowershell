$fencedCodeBlockPattern = '^```powershell\s*$'
$root = "C:\Repos\GitHub\msft\PowerShell-Docs\reference"
$urlRoot = "https://docs.microsoft.com/en-us/powershell/module/"

Get-ChildItem -Path $root -Filter "*.md" -Recurse |
    Select-String -Pattern $fencedCodeBlockPattern -AllMatches |
    Where-Object { $_.Path -notmatch "(about|provider|function|docs-conceptual)" } |
    Select-Object -Property Path -Unique |
    Sort-Object -Property Path |
    ForEach-Object {
        $path = $_.Path.Substring("C:\Repos\GitHub\msft\PowerShell-Docs\reference\".Length)
        $firstDelimiter = $path.IndexOf("\")
        $version = $path.Substring(0, $firstDelimiter)
        $topicpath = $path.Substring($firstDelimiter+1).Replace("\","/").Replace(".md","")
        Write-Output ("{0}{1}?view=powershell-{2}" -f $urlRoot, $topicpath, $version) 
    }
