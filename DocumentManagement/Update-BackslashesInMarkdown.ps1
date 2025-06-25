$candidateDocuments = @{}
Get-ChildItem -Path "C:\GIT\PowerShell-Docs\scripting" -Filter "*.md" -Recurse |
    Select-String -Pattern "\\[^\\]" -AllMatches |
    ForEach-Object {
        if(-not $candidateDocuments.ContainsKey($_.Path)){
            $candidateDocuments.Add($_.Path,1)
        }
    }
$candidateDocuments.Keys.GetEnumerator() | 
    ForEach-Object{
        $document = $_
        [string]$content = [System.IO.File]::ReadAllText($document)
        $content = $content.Replace("\-","-")
        $content = $content.Replace("\+","+")
        $content = $content.Replace("\_","_")
        $content = $content.Replace("\/","/")
        $content = $content.Replace("\#","#")
        $content = $content.Replace("\=","=")
        [System.IO.File]::WriteAllText($document,$content)
    }