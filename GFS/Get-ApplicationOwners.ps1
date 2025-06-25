Import-Module Invoke-JSONMethod

$OutputFile = Join-Path $([Environment]::GetFolderPath("Desktop")) "ApplicationOwners.csv"

if (Test-Path -Path $OutputFile -PathType Leaf)
{
    Remove-Item -Force $OutputFile
}
Write-Host "Sending output to $($OutputFile)"

$pgurl = "http://msidentityapi/directory.svc/Teams()?`$filter=BoundaryNodeType eq 'BRH.Property Group'&`$select=Id,Name"
$pginfo = Invoke-JSONMethod -Uri $pgurl
Write-Host "Found $($pginfo.Count) Property Groups."

$counter = 0
foreach($pg in $pginfo)
{
    Write-Progress -Activity "Fetching Application owners" -Status "Processing Applications under '$($pg.Name)'"  -PercentComplete ($counter*100/$($pginfo.Count))
    $teamurl = "http://msidentityapi/directory.svc/Teams()?`$filter=BoundaryNodeType eq 'BRH.Application' and ParentId eq '$($pg.Id)'&`$expand=UserOwners"
    $results = Invoke-JSONMethod -Uri $teamurl

    $owners = @()
    foreach($team in $results)
    {
        foreach($owner in $team.UserOwners)
        {
            $row = New-Object PSObject -Property @{
                BRHId = $team.BoundaryNodeId
                PropertyGroup = $pg.Name
                PropertyDimension = $team.Name
                DisplayName = $team.DisplayName
                OwnerName = $owner.Name
                OwnerDisplayName = $owner.DisplayName
                CorpAlias = $owner.CorpAlias
            }
            $owners += $row
        }
    }

    $owners | Export-Csv -Path $OutputFile -NoTypeInformation -Append
    $counter++
}