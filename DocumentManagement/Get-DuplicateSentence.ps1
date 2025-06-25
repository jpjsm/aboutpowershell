[string]$docsFolder = "C:\GIT\PowerShell-Docs\reference"
[string]$docExtensionFilter = "*.md"


## [string]$repeatingWordPattern = "\s(?<word>\w+)\s+\k<word>\s"
[string]$repeatingSentencePattern = "(^|[^-\p{L}\p{N}_'])(?<sentence>(\p{L}[-\p{L}\p{N}_']*([.,;:]|\s)\s*)+\p{L}[-\p{L}\p{N}_']*)\s*\k<sentence>"

Get-ChildItem -Path $docsFolder -Filter $docExtensionFilter -Recurse |
    Select-String -Pattern $repeatingSentencePattern -AllMatches |
    ForEach-Object {
        $document = $_.Path
        $linenumber = $_.LineNumber
        $line = $_.Line
        Write-Output "$document $linenumber"
        $_.Matches | 
            ForEach-Object {
                $patternMatch = $_.Groups[0]
                $simpleSentence = $_.Groups["sentence"]
                Write-Output "`t» $patternMatch --> $simpleSentence"
            }
    }