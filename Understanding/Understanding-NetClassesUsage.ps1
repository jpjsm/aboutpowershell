Add-Type -Path "<el directorio donde esta>\Calculator.dll"
$tres = [Calculator.Calculator]::Sum(1,2)
Write-Host "Tres is $tres"

Add-Type -Path "<el directorio donde esta>\Duplicates.dll"

$duplicates = New-Object Duplicates.Duplicates("c:\tmp")

$duplicates.DuplicateGroups

for($i = 0; $i -lt $($duplicates.DuplicateGroups.Count); $i++)
{
    Write-Host "Group: $i"
    $duplicates.DuplicateGroups[$i] | Foreach-Object { Write-Host "    $_"}
}