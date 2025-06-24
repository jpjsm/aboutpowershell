 <#

    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER  DocumentsFolder
        The path to the folder (with subfulders) that contains all MD documents to process.

    .PARAMETER  $Recurse
        A switch to enable recursive folder search.

    .OUTPUTS
        

    .EXAMPLE
        
        
#>
function Expand-AssetIdCmdletReferenceInMdDocuments()
{
    [CmdletBinding()]
    Param(
      [string]$RootFolder ,
      [switch]$Recurse
    )

    $guidPattern = "[0-9A-Za-z]{8}(-[0-9A-Za-z]{4}){3}-[0-9A-Za-z]{12}"
    $assetIdReferencePattern = "\[(?<cmdletVerb>[A-Za-z]+)\\?(?<separator>[_-])(?<cmdletNoun>[A-Za-z]+)[^A-Za-z\]]?[^\]]*\]\((?<link>assetId:///$guidPattern)\)"

    $markdownTopics = @{}
    Get-ChildItem -Path $rootFolder -Filter "*.md" -Recurse:$Recurse | `
        Where-Object { -not $_.PSIsContainer } | `
        ForEach-Object { 
            $filename = $_.Name
            $path = $_.FullName
            if(-not $markdownTopics.ContainsKey($filename)){
                $markdownTopics.Add($filename,@())
            }

            $markdownTopics[$filename] += $path
        }

    $documentUpdates = @{}

    Get-ChildItem -Path $rootFolder -Filter "*.md" -Recurse | `
        Where-Object { -not $_.PSIsContainer } | `
        Select-String -Pattern $assetIdReferencePattern -AllMatches | `
        ForEach-Object { 
            $filename = $_.Path
            $lineNumber = $_.LineNumber
            $_.Matches | `
            ForEach-Object { 
                $match = $_.Groups[0]
                $cmdletReference = $_.Groups["cmdletVerb"].Value + $_.Groups["separator"].Value + $_.Groups["cmdletNoun"].Value
                $oldLink = $_.Groups["link"].Value
                $newLink = $cmdletReference + ".md"
                $newReference = "[$cmdletReference]($newLink)"
                $status = "ERROR"
                if($markdownTopics.ContainsKey($newLink) -and ($markdownTopics[$newLink].Length -eq 1)){
                    if(-not $documentUpdates.ContainsKey($filename)){
                        $documentUpdates.Add($filename, @{})
                    }

                    $documentUpdates[$filename][$match] = $newReference
                    <#
                    if(-not $documentUpdates[$filename].ContainsKey($match)){
                        $documentUpdates[$filename].Add($match,$newReference)
                    }
                    #>
                }
                else{
                    if(-not $markdownTopics.ContainsKey($newLink)){
                        $status = "ERROR: No cmdlet topic found"
                    }
                    else{
                        $status = "ERROR: Multiple cmdlet found" + $markdownTopics[$newLink].Length
                    }

                    Write-Warning "$status [$filename : $lineNumber] $match =» $newReference «= $oldLink" 
                }            
            }
        }

    $documentUpdates.GetEnumerator() | `
        ForEach-Object {
            $filename = $_.Key
            [string]$content = [System.IO.File]::ReadAllText($filename)
            $replacementPairs = $_.Value
            $replacementPairs.GetEnumerator() | `
                ForEach-Object {
                    $oldText = $_.Key
                    $newText = $_.Value

                    write-output "[$filename] $oldText =» $newText"
                    $content = $content.Replace($oldText,$newText)
                }

            [System.IO.File]::WriteAllText($filename, $content)
        }
}