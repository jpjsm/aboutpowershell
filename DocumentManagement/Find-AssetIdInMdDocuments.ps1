
<#
#>
function Find-AssetIdInMdDocuments()
{
    [CmdletBinding()]
    Param(
      [string]$RootFolder ,
      [switch]$Recurse
    )

    Get-ChildItem -Path $rootFolder -Filter "*.md" -Recurse:$Recurse | 
        Select-String "assetId:///" -AllMatches | 
        ForEach-Object { 
            $filename = $_.Path
            $lineNumber = $_.LineNumber
            $_.Matches | `
            ForEach-Object { 
                $match = $_.Groups[0]
                Write-Output "$filename $lineNumber $match"
            }
        }
}
