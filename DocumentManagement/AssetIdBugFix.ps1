<#
Get-ChildItem -Path "C:\GIT\About\v3" -Filter "*.md" -Recurse | `
    Where-Object { -not $_.IsPsContainer } | `
    Select-String -Pattern "\[[a-zA-Z]+(\\)?-[a-zA-Z]+(&#91;.+&#93;)?\]"
#>

$mdDocsFolder = "C:\GIT\PowerShell-Docs\scripting"
Get-ChildItem -Path $mdDocsFolder -Filter "*.md" -Recurse | ` Select-String "assetId:///" | ` Select-Object -Property Path | ` Sort-Object -Property Path -Unique | ` % { $currentpath = $_.Path; ( (Get-Content $currentpath) | % { $_ -creplace "assetId:///","https://technet.microsoft.com/en-us/library/" } | Set-Content -Path $currentpath ) }