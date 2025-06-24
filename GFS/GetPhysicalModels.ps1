[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)][System.String]$modulesPath,
[Parameter(Mandatory=$true)][System.String]$scriptsPath,
[Parameter(Mandatory=$true)][System.String]$folderPath,
[Parameter(Mandatory=$true)][System.Int32]$groupId,
[Parameter(Mandatory=$true)][System.String[]]$connectionNames
)

$start = [DateTime]::UtcNow

$modules = @{}
Get-Module -All| % { $modules[$_.Name] = $true }

if(-Not $modules["fabric"])
{
    Import-Module $(Join-Path $modulesPath -ChildPath "rd_cmt_stable.991231-0001\FcShell\fabric.psd1")
}

if(-Not $modules["DcmTools"])
{
    Import-Module $(Join-Path $modulesPath -ChildPath "DcmTools")
}

if(-Not $modules["Utils"])
{
    Import-Module $(Join-Path $scriptsPath -ChildPath "Utils.psm1")
}


$groupName = "Group_" + $groupId.ToString("0000")
$stringConnectionNames = $connectionNames -join ", "
$global:fileroot = $folderPath

$global:logInformation = $(Join-Path $global:fileroot -ChildPath "$groupName.Information.log")
$global:logWarning = $(Join-Path $global:fileroot -ChildPath "$groupName.Warning.log")
$global:logError = $(Join-Path $global:fileroot -ChildPath "$groupName.Error.log")
$global:logVerbose = $(Join-Path $global:fileroot -ChildPath "$groupName.Verbose.log")
$global:emptyFabrics = $(Join-Path $global:fileroot -ChildPath "$groupName.EmptyFabrics.tsv")

$fabricSummary = @()
$fabricSummaryFilename = $(Join-Path $global:fileroot -ChildPath "@Stats.$groupName.Fabric.log")
$runStatsFilename = $(Join-Path $global:fileroot -ChildPath "@Stats.$groupName.Run.log")

Add-Content -Path $global:logInformation -Value "Starting execution: $start" -PassThru
Add-Content -Path $global:logInformation -Value "groupName  $groupName" -PassThru
Add-Content -Path $global:logInformation -Value "AllConnectionNames $stringConnectionNames" -PassThru
Add-Content -Path $global:logInformation -Value "global:fileroot $global:fileroot" -PassThru
Add-Content -Path $global:logInformation -Value "global:logInformation $global:logInformation" -PassThru
Add-Content -Path $global:logInformation -Value "global:logWarning $global:logWarning" -PassThru
Add-Content -Path $global:logInformation -Value "global:logError $global:logError" -PassThru
Add-Content -Path $global:logInformation -Value "global:logVerbose $global:logVerbose" -PassThru
Add-Content -Path $global:logInformation -Value "fabricSummaryFilename  $fabricSummaryFilename"
Add-Content -Path $global:logInformation -Value "runStatsFilename $runStatsFilename" -PassThru

Add-Content -Path $global:logWarning -Value "logWarning initialized @ $start" -PassThru
Add-Content -Path $global:logError -Value "logError initialized @ $start" -PassThru
Add-Content -Path $global:logVerbose -Value "logVerbose initialized @ $start" -PassThru
Add-Content -Path $global:logInformation -Value "Getting data for: $stringConnectionNames" -PassThru

$fabrics = $null

try
{
    $fabrics = Get-Fabric -CloudName $connectionNames
}
catch 
{
    $ErrorMessage = $_.Exception.Message
    Add-Content -Path $global:logError -Value "[Get-Fabric] failed for: $stringConnectionNames" -PassThru
    Add-Content -Path $global:logError -Value "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Add-Content -Path $global:logError -Value $ErrorMessage 
    Add-Content -Path $global:logError -Value "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" 
    [System.IO.File]::WriteAllLines($global:emptyFabrics, $connectionNames)
    Exit
}

if( -not $fabrics)
{
    Add-Content -Path $global:logError -Value "[Get-Fabric] returned empty for all: $stringConnectionNames" -PassThru
    [System.IO.File]::WriteAllLines($global:emptyFabrics, $connectionNames)
    Exit
}

## Find out which of the expected fabrics didn't come back
if($connectionNames.Length -gt $fabrics.Length)
{
    $namesOfFabricsRetrieved = $fabrics | % { ([RD.Fabric.Controller.PowerShell.ObjectModel.Fabric]$_).Name }
    $namesOfFabricsNotRetrived = $connectionNames | where { $namesOfFabricsRetrieved -notcontains $_ } 
    Add-Content -Path $global:logWarning -Value $("No answer from the following fabric(s): " + ($namesOfFabricsNotRetrived -join ", "))
    [System.IO.File]::WriteAllLines($global:emptyFabrics, $namesOfFabricsNotRetrived)
}

foreach($fabric in $fabrics)
{
    if($fabric -eq $null)
    {
        Add-Content -Path $global:logWarning -Value "Empty fabric found in `$fabrics"
        continue
    }


    $fabricname = ([RD.Fabric.Controller.PowerShell.ObjectModel.Fabric]$fabric).Name
    Add-Content -Path $global:logInformation -Value "Processing physical model for fabric: $fabricname" -PassThru

    ## Making current fabric the default fabric    
    [RD.Fabric.Controller.PowerShell.GetFabric]::DefaultFabricsForSession = $fabric

    $physicalModelPath = Join-Path $global:fileroot -ChildPath $fabricName
    $physicalModel = $null

    try
    {
        $physicalModel = Receive-Repository -Name Microsoft.Windows.Azure.Fabric.DataCenterManager.PhysicalModel -Fabric $fabric -DestinationPath $physicalModelPath
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        Add-Content -Path $global:logError -Value "[Receive-Repository] failed for: $fabricname" -PassThru
        Add-Content -Path $global:logError -Value "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
        Add-Content -Path $global:logError -Value $ErrorMessage 
        Add-Content -Path $global:logError -Value "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^" 
        [System.IO.File]::AppendAllLines($global:emptyFabrics, $fabricname)
    }

    Add-Content -Path $global:logInformation -Value "$fabricname : Physical model succesfully retrieved" -PassThru
}

