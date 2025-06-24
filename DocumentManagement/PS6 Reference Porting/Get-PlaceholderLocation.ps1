function Get-PlaceholderLocation () {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$true)] 
      [ValidateNotNullOrEmpty()]
      [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})] 
      [String] $docsfolder
    ,[parameter(Mandatory=$false)] 
      [String] $filter = "*.md"
    ,[parameter(Mandatory=$false)] 
      [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})] 
      [String] $outfolder
    ,[parameter(Mandatory=$false)] 
      [String] $outfile
    ,[parameter(Mandatory=$false)]
    [Switch]$OnlyFileOutput
    ,[parameter(Mandatory=$false)]
      [ValidateSet("UTF8BOM", "UTF8NOBOM", 
                 "ASCII", "UTF7",
                 "UTF16BigEndian","UTF16LittleEndian","Unicode",
                 "UTF32BigEndian","UTF32LittleEndian")]
      [string] $encode = "UTF8NOBOM"
  )
  
  BEGIN{
    [string]$placeholderpattern = "\{\{(\s*[A-Za-z]+\s*)+\}\}"
    [string[]]$lines = @()
    if($outfolder -and -not $outfile){
      $outfile = "PlaceholderLocations_" + [DateTime]::Now.ToString("yyyy-MM-dd_HHmmss") + ".txt"
    }
  }

  END{
      Get-ChildItem -Path $docsfolder -Filter $filter -Recurse |
        ForEach-Object { if($OnlyFileOutput) { Write-Progress ($_.FullName)}; $_ } |
        Select-String -Pattern $placeholderpattern -AllMatches | 
        ForEach-Object {
          $path = $_.Path
          $linenumber = $_.LineNumber
          $match = $_.Matches[0]
          [string]$line =  "$path`t$linenumber`t$match"
          if (-not $OnlyFileOutput) {
            Write-Output $line
          }

          $lines += $line
        }
        
        if ($outfolder) {
          [System.IO.File]::WriteAllLines((Join-Path -Path $outfolder -ChildPath $outfile), $lines, (Get-EncodingFromLabel -encode $encode))  
        }
  }
}


