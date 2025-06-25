$referenceFolder = "C:\GIT\PowerShell-Docs\reference"
$pattern = "\[([- A-Za-z0-9]+)\]\((00000000-0000-0000-0000-000000000000)\)"

$replacementsNeeded = @{}

Get-ChildItem -Path $referenceFolder -Filter *.md -Recurse |
    Select-String -Pattern $pattern -AllMatches|
    Select-Object -Property Path, Matches | 
    ForEach-Object{
        [string]$docpath = $_.Path
        if(-not $replacementsNeeded.ContainsKey($docpath)){
            $replacementsNeeded.Add($docpath, @{})
        }

        $currentMatches = $_.Matches
        $currentMatches | 
            ForEach-Object {
                [string]$match = $_.Groups[0].Value
                if(-not $replacementsNeeded[$docpath].ContainsKey($match)){
                    [string]$refName = ($_.Groups[1].Value) + ".md"
                    $refName = $refName.Replace(" ","-")
                    [string]$newreference = $match.Replace("00000000-0000-0000-0000-000000000000", $refName)
                    $replacementsNeeded[$docpath].Add($match, $newreference)
                }
            }
    }

$replacementsNeeded.GetEnumerator() |
    ForEach-Object {
        $docPath = $_.Key
        $replacements = $_.Value

        [string]$content = [System.IO.File]::ReadAllText($docPath)

        $replacements.GetEnumerator() |
            ForEach-Object {
                $old = $_.Key
                $new = $_.Value
                $content = $content.Replace($old, $new)

                Write-Host "$docPath : $old --> $new"
            }

        [System.IO.File]::WriteAllText($docPath, $content)
    }
