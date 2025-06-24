$beforeroot = "C:\tmp\PowerShell-Docs\before migration\reference"
$afterroot = "C:\tmp\PowerShell-Docs\after migration\reference"

$before = @{}
$after = @{}

Get-ChildItem -Path $beforeroot -Recurse -Filter "*.md" |
    ForEach-Object {
        Write-Progress $("reviewing BEFORE $_")
        $path = $_.FullName
        $hash = Get-FileHash -LiteralPath $path -Algorithm MD5

        $relativepath = $path.Substring($beforeroot.Length)

        $before.Add($relativepath, @{"hash" = $hash })
    }


Get-ChildItem -Path $afterroot -Recurse -Filter "*.md" |
    ForEach-Object {
        Write-Progress $("reviewing AFTER $_")
        $path = $_.FullName
        $hash = Get-FileHash -LiteralPath $path -Algorithm MD5

        $relativepath = $path.Substring($afterroot.Length)

        $after.Add($relativepath, @{"hash" = $hash })
    }

$before.Keys |
    ForEach-Object {
        $relativepath = $_
        if($after.ContainsKey($relativepath) -and $before[$relativepath]["hash"].Hash -eq $after[$relativepath]["hash"].Hash){
            $before[$relativepath].Add("isMatch",$true)
            $after[$relativepath].Add("isMatch",$true)
        }
    }

$notmatched = $before.GetEnumerator() | Where-Object { -not ($_.Value)["isMatch"] }