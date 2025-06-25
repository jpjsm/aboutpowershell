<#

#>
function New-ReadmeTopicForReferenceContent ()
{
    [CmdletBinding()]
    Param(
      [string]$rootFolder 
    )

    $mdText = 
        "| Module Reference | Cmdlets  | `r`n" + `
        "| - | - | `r`n" 

    $moduleLIst = Get-ChildItem -Path $rootFolder | `
        Where-Object { $_.PSIsContainer } | `
        ForEach-Object {
            [string]$module = $_.Name
            [string]$cmdletList = (Get-ChildItem -Path $_.FullName -Filter "*.md" | `
                Where-Object { 
                    -not $_.PSIsContainer `
                    -and $_.BaseName -ne $module `
                    -and $_.Name -ne "TOC.md" `
                    -and $_.Name -ne "`$`$about_Regular_Express.md"} | `
                ForEach-Object { $basename= $_.BaseName; $filename = $_.Name; "[$basename]($module/$filename)" } | Sort-Object) -join ", "
            $("| [$module]($module/$module.md) | $cmdletList |")
        }


    $mdText = $mdText + $($moduleLIst -join "`r`n")
    $mdText
}