## $docsFolder = "C:\PSReferenceConversion\reference"
$docsFolder = "C:\PSReferenceConversion\reference","C:\GIT\PowerShell-Docs\reference"

$MSAssetIdPattern = "^ms.assetid\s*:\s*(?<guid>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s*$"

Get-ChildItem -Path $docsFolder -Filter "*.md" -Recurse |
    Where-Object { -not $_.PSIsContanier } |
    ForEach-Object{
        $doc = $_.FullName
        $content = [System.IO.File]::ReadAllLines($doc)
        $newcontent = $content -notmatch $MSAssetIdPattern
        [System.IO.File]::WriteAllLines($doc, $newcontent,[System.Text.Encoding]::UTF8)
        Write-Host ("{0}: {1} --> {2}" -f $doc,($content.Length), (($newcontent.Length)))
    }