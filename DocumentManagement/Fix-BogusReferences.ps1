Remove-Variable -Name path -Force -ErrorAction SilentlyContinue
Remove-Variable -Name DocsFolder -Force -ErrorAction SilentlyContinue
Remove-Variable -Name cmdlet1 -Force -ErrorAction SilentlyContinue
Remove-Variable -Name cmdlet2 -Force -ErrorAction SilentlyContinue
Remove-Variable -Name newlink -Force -ErrorAction SilentlyContinue
Remove-Variable -Name docs2fix -Force -ErrorAction SilentlyContinue
Remove-Variable -Name changes -Force -ErrorAction SilentlyContinue
Remove-Variable -Name content -Force -ErrorAction SilentlyContinue
Remove-Variable -Name linkcount -Force -ErrorAction SilentlyContinue
Remove-Variable -Name replacementesmade -Force -ErrorAction SilentlyContinue

[string]$path = [string]::Empty
[string]$cmdlet1 = [string]::Empty
[string]$cmdlet2 = [string]::Empty
[string]$newlink = [string]::Empty
[string]$content = [string]::Empty
[string]$DocsFolder = "C:\GIT\PowerShell-Docs\reference"
[int]$linkcount = 0
[int]$replacementesmade = 0

$docs2fix = @{}
$changes = @{}


$WindowsFileSystemLinkPattern = "\[(?<cmdlet1>[A-Za-z]+-[A-Za-z][A-Za-z0-9]+)\]\(((([^()]*)?(\\[^\\()]*)+)?/)?(?<cmdlet2>[A-Za-z]+-[A-Za-z][A-Za-z0-9]+)\.md\)"

$WindowsFileSystemLinkPattern = "\[(?<cmdlet1>[A-Za-z]+-[A-Za-z][A-Za-z0-9]+)\]\(((([^()]*)?(/[^/()]*)+)?/)?(?<cmdlet2>[A-Za-z]+-[A-Za-z][A-Za-z0-9]+)\.md\)"


Get-ChildItem -Path $DocsFolder -Filter "*.md" -Recurse |
    Select-String -Pattern $WindowsFileSystemLinkPattern -AllMatches |
    ForEach-Object {
        $path = $_.Path

        $_.Matches | 
            ForEach-Object {
                $mtch = $_.Groups[0]
                $cmdlet1 = $_.Groups["cmdlet1"].Value
                $cmdlet2 = $_.Groups["cmdlet2"].Value
                if($cmdlet1 -ne $cmdlet2 ){
                    if(-not $docs2fix.ContainsKey($path)){
                        $docs2fix.Add($path, @{})
                    }

                    $newlink = $mtch.Replace($cmdlet2,$cmdlet1)
                    $docs2fix[$path][$mtch] = $newlink 
                    Write-Progress "$mtch --> $newlink" 
                    $linkcount++
                }
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

