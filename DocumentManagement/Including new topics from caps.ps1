cd "C:\git\PowerShell-Docs"
$InConversion = @{}
Get-ChildItem -Path ".\scripting" -Recurse|? {! $_.PSIsContainer } | % { $_.FullName.Replace("C:\git\PowerShell-Docs\scripting","")}  | %{ $InConversion.Add($_, "")}

$RecentlyAddedTopic = @()
$(Get-ChildItem -Path ".\tmp" -Recurse|? {! $_.PSIsContainer }).count
$RecentlyAddedTopic = Get-ChildItem -Path ".\tmp" -Recurse|? {! $_.PSIsContainer } | ? { ! $InConversion.ContainsKey($_.FullName.Replace("C:\git\PowerShell-Docs\tmp","")) } | select-object -property Fullname

$RecentlyAddedTopic | % { Copy-Item -Path $_.FullName -Destination  $($_.FullName.Replace("\tmp\","\scripting\")) }