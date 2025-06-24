[string]$docsFolder = "C:\GIT\PowerShell-Docs\reference"
[string]$docExtensionFilter = "*.md"
[int]$regexOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase


[string]$repeatingSentencePattern = "(^|[^-\p{L}\p{N}_'])(?<repetition>(?<sentence>(\p{L}[-\p{L}\p{N}_']*([.,;:]|\s)\s*)+\p{L}[-\p{L}\p{N}_']*)\s*\k<sentence>)"

$repeatedSentences = @{}

Get-ChildItem -Path $docsFolder -Filter $docExtensionFilter -Recurse |
    ForEach-Object {
        $document = $_.FullName
        $content = [System.IO.File]::ReadAllText($document)

        $matches = [System.Text.RegularExpressions.Regex]::Matches($content,$repeatingSentencePattern,$regexOptions)
        
        if($matches.Count -gt 0) {
            Write-Verbose " "
            Write-Verbose "$document :"
            $matches.GetEnumerator() |
                ForEach-Object {
                    $patternMatch = $_.Groups["repetition"].Value
                    $simpleSentence = $_.Groups["sentence"].Value
                    $patternMatchPrintable = $patternMatch.Replace("`r`n","¶")
                    $simpleSentencePrintable = $simpleSentence.Replace("`r`n","¶")

                    if(-not $repeatedSentences.ContainsKey($patternMatchPrintable)){
                        $repeatedSentences.Add($patternMatchPrintable, @{"PatternMatch" = $patternMatch; "SimpleSentence" = $simpleSentence })
                    }

                    Write-Verbose "`t******"
                    Write-Verbose "`t« $patternMatchPrintable"
                    Write-Verbose "`t---- "
                    Write-Verbose "`t» $simpleSentencePrintable"
                    Write-Verbose " "
                }
            Write-Verbose " "
            Write-Verbose "------------------------------------------------------------------------------"
            Write-Verbose " "
        }  
    }

