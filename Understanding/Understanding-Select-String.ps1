<#
    .SYNOPSIS
    Getting a basic understating of Select-String

    .DESCRIPTION
    This codes and the associated test files should provide an initial understanding
    of how does Select-String works.

    The output of a Select-String cmdlet is always the information on files that have 
    a match on the pattern provided.

    The test pattern looks for text exclosed in bar | characters.

#>

$testFolder = "C:\tmp\Test Select-String"

$pattern = "\|[^|]+\|"

Get-ChildItem -Path $testFolder |
    Select-String -Pattern $pattern -AllMatches|
    ForEach-Object { 
        $linenumber = $_.LineNumber;  
        $path = $_.Path
        $_.Matches | 
            ForEach-Object { 
                $_.Captures | 
                ForEach-Object { 
                    Write-Output $("{0} : {1} : {2}" -f $path, $linenumber, $_.Value) 
                } 
            } 
    } 