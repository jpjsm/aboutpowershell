$unwantedchar = "Â®"
$replacementchar ="®"

## $unwantedcharPattern = "[^A-Za-z0-9 ]®"
$unwantedcharPattern = ".®"
$docsFolder = "C:\PSReferenceConversion\reference","C:\GIT\PowerShell-Docs\reference"

$unwantedBlocks = @{}
Get-ChildItem -Path $docsFolder -Filter "*.md" -Recurse |
    Where-Object { -not $_.PSIsContanier } |
    Select-String -Pattern $unwantedcharPattern -AllMatches |
    ForEach-Object{
        $doc = $_.Path
        $_.Matches | 
            ForEach-Object {
                [string]$uw = $_.Groups[0].Value
                $unwantedBlocks[$uw] += 1
            }
        Write-Host "Processed: $doc"
    <#
        $doc = $_.FullName
        [string]$content = [System.IO.File]::ReadAllText($doc)
        $newcontent = $content.Replace($unwantedchar, $replacementchar)
        [System.IO.File]::WriteAllLines($doc, $newcontent, [System.Text.Encoding]::UTF8)
    #>
    }

$unwantedBlocks