$pattern = "{{[^{}]+}}"
[string]$referencepath = "C:\GIT\PowerShell-Docs\reference\"
[string]$scriptingpath = "C:\GIT\PowerShell-Docs\scripting\"
[string[]]$rootfolders = @($referencepath, $scriptingpath)

$docstofix = @{}
Get-ChildItem -Path $rootfolders -Recurse -Filter "*.md" |
    Select-String -Pattern $pattern -AllMatches |
    ForEach-Object {
        $doc = $_.Path
        [string]$linenumber = $_.LineNumber

        if(-not $docstofix.ContainsKey($doc)) {
            $docstofix.Add($doc, @{})
        }

        $_.Matches |
            ForEach-Object {
                $placeholder = $_.Groups[0].Value

                if(-not $docstofix[$doc].ContainsKey($placeholder)) {
                    $docstofix[$doc].Add($placeholder, @())
                }

                $docstofix[$doc][$placeholder] += $linenumber
            }
    }

[string[]]$outputlines = @()
$docstofix.GetEnumerator() |
    ForEach-Object {
        [string]$doc = $_.Key

        $docset = [string]::Empty
        $library = [string]::Empty
        $version = [string]::Empty
        $document = [System.IO.Path]::GetFileName($doc)

        if($doc.StartsWith($referencepath)) {
            $docset = "reference"
            $library = [System.IO.Path]::GetDirectoryName($doc.Substring($scriptingpath.Length))
            $version = $library.Substring(0,3)
            $library = $library.Substring(4)
        }

        if($doc.StartsWith($scriptingpath)) {
            $docset = "scripting"
            $library = [System.IO.Path]::GetDirectoryName($doc.Substring($scriptingpath.Length))
        }

        $_.Value.GetEnumerator() |
            ForEach-Object {
                $placeholder = $_.Key
                $linenumbers = [string]::Join(",", $_.Value)
                $linecount = $_.Value.Count
                [string]$line = "$doc`t$docset`t$version`t$library`t$document`t$placeholder`t$linecount`t$linenumbers"
                Write-Output $line
                $outputlines += $line
            }
    }

[System.IO.File]::WriteAllLines("c:\tmp\placeholders.tsv", $outputlines)