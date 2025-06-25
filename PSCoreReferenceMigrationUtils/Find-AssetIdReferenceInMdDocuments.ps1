## Find documents with AssetId references

function Find-AssetIdReferenceInMdDocuments()
{
    [CmdletBinding()]
    Param(
      [string]$RootFolder ,
      [switch]$Recurse
    )

    $guidPattern = "[0-9A-Za-z]{8}(-[0-9A-Za-z]{4}){3}-[0-9A-Za-z]{12}"
    $assetIdReferencePattern = "\[(?<cmdletVerb>[A-Za-z]+)\\?-(?<cmdletNoun>[A-Za-z]+)[^A-Za-z\]]?[^\]]*\]\((?<link>assetId:///$guidPattern)\)"

    Get-ChildItem -Path $rootFolder -Filter "*.md" -Recurse | `
        Where-Object { -not $_.PSIsContainer } | `
        Select-String -Pattern $assetIdReferencePattern -AllMatches | `
        ForEach-Object { 
            $filename = $_.Path
            $lineNumber = $_.LineNumber
            $_.Matches | `
            ForEach-Object { 
                $match = $_.Groups[0]
                $cmdletReference = $_.Groups["cmdletVerb"].Value + "-" + $_.Groups["cmdletNoun"].Value
                $oldLink = $_.Groups["link"].Value
                $newLink = $cmdletReference + ".md"
                $newReference = "[$cmdletReference]($newLink)"
                $status = "ERROR"
                Write-Warning "$status [$filename : $lineNumber] $match =» $newReference «= $oldLink" 
            }
        }
}