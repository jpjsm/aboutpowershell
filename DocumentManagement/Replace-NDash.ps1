## Define UTF8 No-BOM encoder/decoder$Utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

$ndash = "–"
$hyphen = "-"
$root = "C:\GIT\PowerShell-Docs\reference"

$docs2fix = @{}
Get-ChildItem -Path $root -Filter "*.md" -Recurse |
    Select-String -SimpleMatch $ndash |
    ForEach-Object {
        $path = $_.Path
        $linenumber = $_.LineNumber
        $docs2fix[$path] = $linenumber
        Write-Output "$path $linenumber"
    }

$docs2fix.Keys.GetEnumerator() |
    ForEach-Object {
        $doc = $_
        [string]$content = [System.IO.File]::ReadAllText($doc, $Utf8NoBom)
        $content = $content.Replace($ndash, $hyphen)
        [System.IO.File]::WriteAllLines($doc , $content, $Utf8NoBom)
        Write-Output "Updated: $doc"
    }