Remove-Variable -Name docsfolder -Force -ErrorAction SilentlyContinue
Remove-Variable -Name VarMentionPattern -Force -ErrorAction SilentlyContinue
Remove-Variable -Name path -Force -ErrorAction SilentlyContinue
Remove-Variable -Name match -Force -ErrorAction SilentlyContinue
Remove-Variable -Name linenumber -Force -ErrorAction SilentlyContinue
Remove-Variable -Name totalMentions -Force -ErrorAction SilentlyContinue
Remove-Variable -Name docs2review -Force -ErrorAction SilentlyContinue
Remove-Variable -Name matches2review -Force -ErrorAction SilentlyContinue

Set-StrictMode -Version Latest
[string] $path = [string]::Empty
[string] $match = [string]::Empty

[int]$linenumber = 0
[int]$totalMentions = 0

[string]$docsfolder = "C:\GIT\PowerShell-Docs\reference"

[string]$VarMentionPattern = '\$[A-Za-z]+[/\\]'


$docs2review = @{}
$matches2review = @{}

Get-ChildItem -Path $docsfolder -filter "*.md" -Recurse |
    Select-String -Pattern $VarMentionPattern -AllMatches |
    ForEach-Object {
        $path = $_.Path
        $linenumber = $_.LineNumber
        if(-not $docs2review.ContainsKey($path)) {
            $docs2review.Add($path, @{})
        }

        $_.Matches |
            ForEach-Object {
                $match = $_.Groups[0].Value

                if(-not $matches2review.ContainsKey($match)){
                    $matches2review.Add($match, @{})

                    $matches2review[$match].Add("linenumbers", @())
                    $matches2review[$match].Add("Count", 0)
                    $matches2review[$match].Add("Documents", @())
                }

                if(-not $docs2review[$path].ContainsKey($match)){
                    $docs2review[$path].Add($match, @{})

                    $docs2review[$path][$match].Add("linenumbers", @())
                    $docs2review[$path][$match].Add("Count", 0)
                }

                $docs2review[$path][$match]["linenumbers"] += $linenumber
                $docs2review[$path][$match]["Count"] += 1

                $matches2review[$match]["linenumbers"] += $linenumber
                $matches2review[$match]["Count"] += 1
                $matches2review[$match]["Documents"] += $path

                Write-Progress ("{0,-20} {1,6:N0} {2}" -f $match, $linenumber, ($docs2review[$path][$match]["Count"]))
            }
    }

Write-Host ("Total documents {0:N0}" -f ($docs2review.Count))

Write-Host "Variables Matched"
$matches2review.GetEnumerator() |
    ForEach-Object {
        $match = $_.Key
        Write-Host ("{0,-20} {1,6:N0}" -f $match, ($matches2review[$match]["Count"]))
    }

