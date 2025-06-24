## Adapted from: @N3WJACK // find and delete duplicate files with just Powershell; http://n3wjack.net/2015/04/06/find-and-delete-duplicate-files-with-just-powershell/
get-childitem ("c:\tmp","C:\users\jpjofre\Pictures","C:\users\jpjofre\documents") -recurse |
 where-object { -not $_.PSIsContainer } |
 group-object -property Length |
 where { $_.Count -gt 1 } |
 foreach-object { $_.Group | get-filehash | group -Property hash | ? { $_.count -gt 1 } } |
 foreach-object { Write-Host $_.Name $($_.Group | Select -property Path) }

