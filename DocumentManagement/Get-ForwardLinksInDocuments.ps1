Get-ChildItem -Path "C:\GIT\PowerShell-Docs\reference" -Filter "*.md" -Recurse | `
    Where-Object { $_.FullName -notlike "*ignore*"} | `
    Select-String -Pattern "http.*?/fwlink/.*?\?linkid=(?<LinkId>[0-9]+)" -AllMatches | `
    ForEach-Object {
        $path = $_.Path
        $linenumber = $_.LineNumber
        $line = $_.line
        $Matches = $_.Matches
        $Matches | ForEach-Object {
            $fwlink = $_.Groups[0]
            $linkid = $_.Groups["LinkId"]
            "$path`t$linenumber`t$linkid`t$fwlink"

        }

    } 1>c:\tmp\fwdlinks.tsv

