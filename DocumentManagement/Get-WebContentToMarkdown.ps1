function Get-WebContentToMarkdown {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$true)] 
      [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]
      [String] 
      $outputfolder,    
    [parameter(Mandatory=$true)] 
      [ValidateNotNull()]
      [hashtable] 
      $inputPages   
  )

  $pandocexe = (Get-Command "pandoc.exe").Source  if(-not $pandocexe){    throw [System.IO.FileNotFoundException]::new("pandoc.exe not available")  }
  $inputPages.GetEnumerator() |      ForEach-Object {          [string]$title = $_.Key          [string]$url = $_.Value          [string]$mdfile = $title.ToLowerInvariant().Replace(" ", "-").Replace("--", "-") + ".md"          $mdfile = Join-Path -Path $outfolder -ChildPath $mdfile          &  $pandocexe -w markdown_github -s -o $mdfile $url      }}
