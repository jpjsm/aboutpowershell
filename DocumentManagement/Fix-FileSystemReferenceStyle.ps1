Remove-Variable -Name path -Force -ErrorAction SilentlyContinue
Remove-Variable -Name DocsFolder -Force -ErrorAction SilentlyContinue
Remove-Variable -Name label -Force -ErrorAction SilentlyContinue
Remove-Variable -Name reference -Force -ErrorAction SilentlyContinue
Remove-Variable -Name newlink -Force -ErrorAction SilentlyContinue
Remove-Variable -Name docs2fix -Force -ErrorAction SilentlyContinue
Remove-Variable -Name changes -Force -ErrorAction SilentlyContinue
Remove-Variable -Name content -Force -ErrorAction SilentlyContinue
Remove-Variable -Name linkcount -Force -ErrorAction SilentlyContinue
Remove-Variable -Name replacementesmade -Force -ErrorAction SilentlyContinue

[string]$path = [string]::Empty
[string]$label = [string]::Empty
[string]$reference = [string]::Empty
[string]$newlink = [string]::Empty
[string]$content = [string]::Empty
[string]$DocsFolder = "C:\GIT\PowerShell-Docs\reference"
[int]$linkcount = 0
[int]$replacementesmade = 0

$docs2fix = @{}
$changes = @{}

$WindowsFileSystemLinkPattern = "(?<label>\[[^\[\]]+\])\((?<reference>([^()]*)?(\\[^\\()]*)+)\)"
Get-ChildItem -Path $DocsFolder -Filter "*.md" -Recurse |
    ForEach-Object { 
        Write-Progress "File name " $_.FullName
        $_
    } |
    Select-String -Pattern $WindowsFileSystemLinkPattern -AllMatches |
    ForEach-Object {
        $path = $_.Path
        if(-not $docs2fix.ContainsKey($path)){
            $docs2fix.Add($path, @{})
        }

        $_.Matches | 
            ForEach-Object {
                $mtch = $_.Groups[0]
                $label = $_.Groups["label"].Value
                $reference = $_.Groups["reference"].Value
                if($reference.StartsWith(".\")){
                    $reference = $reference.Substring(2)
                }

                $newlink = "{0}({1})" -f $label,($reference.Replace("\","/"))
                $docs2fix[$path][$mtch] = $newlink 
                Write-Progress "$mtch --> $newlink" 
                $linkcount++
            }
    }

$docs2fix.GetEnumerator() |
    ForEach-Object {
        $path = $_.Key
        $changes = $_.Value
        $content = [System.IO.File]::ReadAllText($path)

        $changes.GetEnumerator() |
            ForEach-Object {
                $old = $_.Key
                $new = $_.Value

                $content = $content.Replace($old, $new)
                Write-Host "$path :: replaced »$old« --> »$new«" 
                $replacementesmade++
            }

        [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    }

Write-Host "Links fixed:       $linkcount"
Write-Host "Replacements made: $replacementesmade"

