Get-ChildItem -Path C:\tmp -Recurse |
ForEach-Object {
    $drive = $_.Directory
    $name = $_.BaseName
    Write-Host "$drive -- $name"
}