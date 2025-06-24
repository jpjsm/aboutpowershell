function Resolve-AssetIdGuidReferences()
{
    [CmdletBinding()]
    Param(
      [string]$DocumentsFolder 
    )

    $AssetIdGuidPattern = "\[(?<text>[^!\[\]]*?)\]\((?<reference>(assetid:///)?(?<guid>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}))\)" 
    $baseUrl = "https://technet.microsoft.com/en-us/library/"

    $docs = @{}
    $guidCache = @{}
    Get-ChildItem -Path $DocumentsFolder -Filter "*.md" -Recurse |
     select-string -Pattern $AssetIdGuidPattern -AllMatches |
     ForEach-Object { 
        [string]$document = $_.Path
        [string]$linenumber = $_.LineNumber.ToString()

        if(-not $docs.ContainsKey($document)){
            $docs.Add($document, @{})
        }

        $_.Matches | 
            ForEach-Object {
                [string]$match = $_.Groups[0].Value
                [string]$text = $_.Groups["text"].Value
                [string]$reference = $_.Groups["reference"].Value
                [string]$guid = $_.Groups["guid"].Value
                [string]$newText = [string]::Empty

                if(-not $guidCache.ContainsKey($guid)){
                    $url = [System.IO.Path]::Combine($baseUrl, $guid)

                    $page = Invoke-WebRequest -URI $url

                    $pageContent = $page.Content
                    $title = select-string -InputObject $pageContent -Pattern "<title>(?<title>[-_ A-Z0-9]+)</title>" | 
                                ForEach-Object {
                                    $_.Matches[0].Groups["title"].Value
                                }
                    if(-not [string]::IsNullOrWhiteSpace($title)){
                        $title = $title.Replace(" ", "-")
                        $newText = "[{0}]({1}.md)" -f $text, $title
                    }
                    
                    $guidCache.Add($guid, $newText)                
                }
                else{
                    $newText = $guidCache[$guid]
                }

                if(-not [string]::IsNullOrWhiteSpace($newText)){

                    if(-not $docs[$document].ContainsKey($match)){
                        $docs[$document].Add($match,$newText)
                    }

                    Write-Progress "Match found" ("{0,-120} {1,5} {2,-80} »»» {3}" -f $document, $linenumber, $match, $newText)
                }
            }            
     } 

     $docs.GetEnumerator() |
        ForEach-Object{
            [string]$documentPath = $_.Key
            [hashtable]$replacements = $_.Value

            [string]$content = [System.IO.File]::ReadAllText($documentPath)

            $replacements.GetEnumerator() |
                ForEach-Object {
                    $oldtext = $_.Key
                    $newtext = $_.Value

                    $content = $content.Replace($oldtext, $newtext)
                    Write-Progress "Doc updated:" ("{0,-120} replaced {1,-80} »»» {2}" -f $documentPath, $oldtext, $newText)
                }

            [System.IO.File]::WriteAllText($documentPath, $content, [System.Text.UTF8Encoding]::UTF8)
        }
}

