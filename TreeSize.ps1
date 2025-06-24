$root = get-item C:\
Get-ChildItem $root -Recurse | Measure-Object -Property Length -sum