function Set-MDInDocumentReference(){
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)] 
        [ValidateScript( { Test-Path -LiteralPath $_ -PathType leaf })] 
        [string]$DocumentPath
        , [ValidateSet("UTF8BOM", "UTF8NOBOM", 
            "ASCII", "UTF7",
            "UTF16BigEndian", "UTF16LittleEndian", "Unicode",
            "UTF32BigEndian", "UTF32LittleEndian")]
        [string] $encode = "UTF8NOBOM"
    )

    BEGIN{
        [string]$mdLinkPattern = '\[(?<text>[^\[\]]+?)\]\((?<link>[^\(\)]+(\([^\(\)]+\))?[^\(\)]+?)?#(?<indocref>[^\(\)]+?)\)'
        [System.Collections.Generic.Dictionary[String,String]]$replacements = [System.Collections.Generic.Dictionary[String,String]]::new()
    }

    END {
        [string]$content = [System.IO.File]::ReadAllText($DocumentPath)

        Select-String -Pattern $mdLinkPattern -InputObject $content -AllMatches |
            ForEach-Object {
                $_.Matches | 
                    ForEach-Object {
                        [string]$oldmatch = $_.Groups[0].Value
                        [string]$newtext = [string]::Empty
                        if([string]::IsNullOrWhiteSpace($_.Groups["link"].Value)){
                            $newtext = '[' + $_.Groups["text"].Value + '](#' + $_.Groups["indocref"].Value + ')'
                        }
                        else {
                            [string]$newtext = '[' + $_.Groups["text"].Value + '](' + $_.Groups["link"].Value + '#' + $_.Groups["indocref"].Value + ')'
                        }
                        $replacements[$oldmatch] = $newtext.ToLowerInvariant()
                    }
            }

        $replacements.Keys.Foreach({$content = $content.Replace($_, $replacements[$_])})
        [System.IO.File]::WriteAllText($DocumentPath, $content, (Get-EncodingFromLabel -encode $encode))
    }
}