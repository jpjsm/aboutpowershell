[string[]]$emptyLine = @( [string]::Empty )
$docsFolder = "C:\PSReferenceConversion\reference","C:\GIT\PowerShell-Docs\reference"
Get-ChildItem -Path $docsFolder -Filter "*.md" -Recurse |
    Where-Object { -not $_.PSIsContanier } |
    ForEach-Object{
        $doc = $_.FullName
        [string[]]$content = [System.IO.File]::ReadAllLInes($doc)
        if($content.Length -gt 0){      
            [int]$lastNonEmptyLine = $content.Length - 1      
            while([System.Text.RegularExpressions.Regex]::IsMatch($content[$lastNonEmptyLine],"^\s*$")){
                $lastNonEmptyLine--
            }
            $newcontent = $content[0..$lastNonEmptyLine] + $emptyLine
            [System.IO.File]::WriteAllLines($doc, $newcontent, [System.Text.Encoding]::UTF8)
            Write-Host ("{0} {1:N0} --> {2:N0}" -f $doc, ($content.Length), ($newcontent.Length))
        }
    }