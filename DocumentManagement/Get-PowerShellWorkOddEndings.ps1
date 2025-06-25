$baseFolder = "C:\GIT\PowerShell-Docs\reference"
$mergeFolder = "C:\PSReferenceConversion\reference"

$powershellSuffixes = @{}
Get-ChildItem -Path ($baseFolder,$mergeFolder) -Filter "*.md" -Recurse |
    Select-String -Pattern "powershell[^-_ :?(``'}{,/;`">).\\*]" -AllMatches |
    ForEach-Object {
        $doc = $_.Path
        $_.Matches |
            ForEach-Object {
                $matchedPattern = $_.Groups[0].Value
                $powershellSuffixes[$_.Groups[0].Value] += 1

                Write-Progress "»$matchedPattern« $doc"
            }
    }

$powershellSuffixes