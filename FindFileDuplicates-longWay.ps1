$sizeTable = @{}
$duplicateGroups =@{}
Get-ChildItem ("c:\tmp","C:\users\jpjofre\Pictures","C:\users\jpjofre\documents") -Recurse| ? { -not $_.PSIsContainer }| % { if(-not $sizeTable[$_.Length]) { $sizeTable[$_.Length]=@() }; $sizeTable[$_.Length] += $_; }
$sizeCandidates = $sizeTable.GetEnumerator() | ? { $_.Value.Length -gt 1 }
foreach($kvp in $sizeCandidates)
{
    $tmphash = @{}
    $kvp.Value | % { $hash = (Get-FileHash -Path $_.PSPath).Hash; if (-not $tmphash[$hash]){ $tmphash[$hash]= @() }; $tmphash[$hash] += $_; } 
    $tmphash.GetEnumerator() | ? { $_.Value.Length -gt 1 } | % { $duplicateGroups.Add($_.Key, $_.Value) }
}

$groupId = 1
foreach($duplicates in  $duplicateGroups.GetEnumerator())
{
    Write-Host "Group # $groupId $($duplicates.Key)"
    $duplicates.Value | % { Write-Host "    $($_.PSPath)"}  
    $groupId++
}