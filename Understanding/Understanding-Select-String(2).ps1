$pattern = "^(?<tag>manager|author|ms\.custom)\s*:\s*(?<value>.*)$"
 
$lines = @() 
Get-ChildItem -Path "C:\GIT\PowerShell-Docs\reference" -Filter "*.md" -Recurse |
    ForEach-Object {
        $path = $_.FullName
        $manager = [string]::Empty
        $author = [string]::Empty
        $custom = [string]::Empty

        $matches = Select-String -Pattern $pattern -LiteralPath $path -AllMatches 
        $matches | 
            ForEach-Object {
                $tag = $_.Matches[0].Groups["tag"].Value
                $value = $_.Matches[0].Groups["value"].Value

                if($tag -eq "manager"){
                    $manager = $value
                }

                if($tag -eq "author"){
                    $author = $value
                }

                if($tag -eq "ms.custom"){
                    $custom = $value
                }
            }

        $lines += "$manager,$author,$custom,$path"

    }

    [System.IO.File]::WriteAllLines("c:\tmp\foo.txt", $lines)