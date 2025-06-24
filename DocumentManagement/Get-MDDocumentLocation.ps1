$ScriptFolder = "C:\Git\PowerShell-Docs\scripting"

Get-ChildItem -Path $ScriptFolder -Filter "*.md" -Recurse |`    Where-Object { -not $_.PSIsContainer } |`    ForEach-Object { Write-Output $("{0}`t{1}" -f $_.Name, $_.FullName.Substring($ScriptFolder.Length + 1))} > C:\tmp\DocumentMap.tsv