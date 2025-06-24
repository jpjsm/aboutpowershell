## Get-ChildItem -Path *.md -Recurse | select-string "assetId" -SimpleMatch | select-object -Property filename,linenumber | %{ "{0,-64} {1,6}" -f $_.filename, $_.linenumber }
## Get-ChildItem -Path *.md -Recurse | select-string "\[(.*?)\]\(\w*assetid\w*:(\/+| )([-0-9a-z]{36})\)" -AllMatches | % { $_.Matches } | % { $_.groups[0] }



## !!!   Get-ChildItem -Path *.md -Recurse | select-string "\[([^!]*?)\]\(.+?([-0-9a-z]{36})\w*\)" -AllMatches | % { $_.Matches } | % { $_.groups[1].Captures[0].Value } 
cd "C:\GIT\PowerShell-Docs\scripting"
$links = @()
$responses = @()
$texts = @{}
Get-ChildItem -Path *.md -Recurse |`
 select-string "\[([^!]*?)\]\(.+?([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\w*\)" -AllMatches |`
 % { 
        $text = $_.Matches.groups[1].Captures[0].Value;
        $guid = $_.Matches.groups[2].Captures[0].Value;
        $links += @{"path" = $_.path; "linenumber" = $_.linenumber; "text" = $text ; "guid" = $guid };
        if(-not $texts.ContainsKey($text)) { $texts.Add( $text, '' ) }
 } 
foreach( $text in $texts.Keys)
{
    $query = $text.Replace(" ", "+")
    $query = $query.Replace("&", "")
    $query = $query.Replace("[", "")
    $query = $query.Replace("]", "")
    while($query -like "*++*") { $query = $query.Replace("++", "+")}
    $pageUrl = "http://www.bing.com/search?q=PowerShell+$query"
    $r =  Invoke-WebRequest -URI $pageUrl
    $responses += $r
} 

$links | % { write-output $("{0,-80}`t{1,4}`t{2}`t{3}" -f $_.path,$_.linenumber,$_.guid,$_.text) }