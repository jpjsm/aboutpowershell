$brokenlinksfile = "C:\tmp\ExternalReferencesToV51.tsv"
$folder = "C:\GIT\PowerShell-Docs\reference\5.1"
$staticlinkroot = "https://msdn.microsoft.com/en-us/powershell/reference/5.1/"

$references = @{}

# Build references dictionary
Get-ChildItem -Path $folder -Filter "*.md" -Recurse |
ForEach-Object {
  $doc = $_.Name
  $path = $_.FullName
    
  if (-not $references.ContainsKey($doc))
  {
    $references.Add($doc, @())
  }
    
  $references[$doc] += $path
}
  
# Build broken links dictionary
$brokenlinks = @{}
[string[]]$lines = [System.IO.File]::ReadAllLines($brokenlinksfile)
$lines |
ForEach-Object {
  [string[]]$items = $_.Split("`t")
  [string]$doc = $items[0]
  [string]$reference = $items[1]
  [string]$missingdocument = $items[2]
  
  if (-not $brokenlinks.ContainsKey($doc))
  {
    $brokenlinks.Add($doc, @{})
  }
  
  if (-not $brokenlinks[$doc].ContainsKey($missingdocument))
  {
    $brokenlinks[$doc].Add($missingdocument,@())
  }
  
  $brokenlinks[$doc][$missingdocument] += $reference
}

$brokenlinks.GetEnumerator() | 
  ForEach-Object{ 
    $docpath= $_.Key
    [string]$doctext = [System.IO.File]::ReadAllText($docpath)
    $orginalhash = Get-HashValueFromString($doctext)
    $_.Value.GetEnumerator() | 
    ForEach-Object { 
      $ref = $_.Key      
      $links = $_.Value
      
      if($references.ContainsKey($ref)) {
        [string]$staticlink = $staticlinkroot + $references[$ref].Substring($folder.Length+1).Replace('\','/').Replace(".md",[string]::Empty)
        
        $links |
          ForEach-Object {
            [string]$oldlink = $_
            [string]$newlink = $oldlink.Substring(0, $oldlink.IndexOf('(') + 1) + $staticlink + ")"
            Write-Output "$oldlink --> $newlink"
            $doctext =$doctext.Replace($oldlink, $newlink)
          }        
      } 
    }
    
    $newhash = Get-HashValueFromString($doctext)
    
    if ($orginalhash -ne $newhash)
    {
      [System.IO.File]::WriteAllText($docpath, $doctext)
    }
    
  }