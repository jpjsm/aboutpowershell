<#

#>
function update-cmdletReferences ()
{
    [CmdletBinding()]
    Param(
      [string]$rootFolder 
    )

    $cmdletNamePattern = "(^|\s+|['`"])[A-Za-z]+\\?-[A-Za-z]+($|\s+|"
}