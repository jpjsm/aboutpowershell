## Define UTF8 No-BOM encoder/decoder$Utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

$pattern = "(?<powershell>PowerShell(?<unknkown>[^-.,:; ®©\t\]*()\['``}/\\>`"23VCRGWHsTdPIbEl_?])).{0,2}"
$root = "C:\GIT\PowerShell-Docs\reference\"
$doc2fix = @{}

[string]$newtext = "PowerShell®"

Get-ChildItem -Path $root -Filter "*.md" -Recurse |
    Select-String -Pattern $pattern -AllMatches |
    ForEach-Object {
        $path = $_.Path
        [int]$linenumber = $_.LineNumber
        $_.Matches | 
            ForEach-Object {
                $powershelltext = $_.Groups["powershell"].Value
                if(-not $doc2fix.ContainsKey($path)) {
                    $doc2fix.Add($path, @{})
                }

                $doc2fix[$path][$powershelltext] += 1 
            }
    }

$doc2fix.GetEnumerator() |
    ForEach-Object {
        $path = $_.Key
        $_.Value.GetEnumerator() |
            ForEach-Object {
                [string]$oldtext = $_.Key
                Write-Output "Updating: $path » $oldtext"
                [string]$content = [System.IO.File]::ReadAllText($path, $Utf8NoBom)                $content = $content.Replace($oldtext, $newtext)                [System.IO.File]::WriteAllText($path, $content, $Utf8NoBom)
            }
    }