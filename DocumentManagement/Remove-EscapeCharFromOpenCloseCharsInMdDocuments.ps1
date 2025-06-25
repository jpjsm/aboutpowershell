function Remove-EscapeCharFromOpenCloseCharsInMdDocuments()
{
    [CmdletBinding()]
    Param(
      [string]$DocumentsFolder
    )

    $openclosechars = @{ 
        "<" = ">" ;
        "[" = "]" ;
        "{" = "}" ;
        "(" = ")" 
    }

    Get-ChildItem -Path $DocumentsFolder -Filter "*.md" -recurse |`
        Where-Object { $_.Directory.FullName -notlike "*.ignore*" -and (-not $_.PSIsContainer)} |
            ForEach-Object {
                [string]$docpath = $_.FullName
                [string]$content = [System.IO.File]::ReadAllText($docpath)

                $replacements = @{}
                $openclosechars.GetEnumerator() |
                    ForEach-Object{
                        [string]$openchar = $_.Key
                        [string]$closechar = $_.Value
                        if($openchar -eq "["){
                            $opencloseescapedPattern = "(?<Open>\\\" + $openchar + ")(?<content>[^\" + $openchar + "\"  + $closechar + "]*)(?'Close-Open'\\\" + $closechar + ")(?(Open)(?!))"
                        }
                        else{
                            $opencloseescapedPattern = "(?<Open>\\" + $openchar + ")(?<content>[^" + $openchar + $closechar + "]*)(?'Close-Open'\\" + $closechar + ")(?(Open)(?!))"
                        }

                        $match = Select-String -Pattern $opencloseescapedPattern -InputObject $content -AllMatches |
                            ForEach-Object{
                                $_.Matches |
                                    ForEach-Object {
                                        [string]$old = $_.Groups[0]
                                        [string]$new = $openchar + $_.Groups["content"] + $closechar
                                        $replacements[$old] = $new
                                    }
                            }                
                    }

                $replacements.GetEnumerator() |
                    ForEach-Object{
                        [string]$old = $_.Key
                        [string]$new = $_.Value
                        $content = $content.Replace($old, $new)                    
                    }

                [System.IO.File]::WriteAllText($docpath, $content,[System.Text.UTF8Encoding]::UTF8)
            }
}

