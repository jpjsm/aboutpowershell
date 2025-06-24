[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)][System.String]$modulesPath,
[Parameter(Mandatory=$true)][System.String]$scriptsPath,
[Parameter(Mandatory=$true)][System.String]$binPath,
[Parameter(Mandatory=$true)][System.String]$resultsPath,
[Parameter(Mandatory=$true)][System.Int32]$maxConcurrentScripts
)

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


## Task definitions
$executable = "powershell.exe"
$script = Join-Path $scriptsPath -ChildPath "GetPhysicalModels.ps1"

## Concurrent Tasks throttling definitions
$MaxConcurrentTasks = $maxConcurrentScripts 
$ActiveTasks = @{}

## Output data (aka results) location
$global:fileroot = $resultsPath
if (-not (test-path $global:fileroot))
{
    Write-Error -Message "DCM results data folder not found."
    Write-Host "DCM data folder not found"
    Exit;
}

##   Creating a hierarchical DateTime folder structure
$global:start = [DateTime]::UtcNow
$dateElements = @()
$dateElements += $global:start.Year.ToString("00")
$dateElements += $global:start.Month.ToString("00")
$dateElements += $global:start.Day.ToString("00")
$dateElements += $global:start.TimeOfDay.ToString("hhmmssffffff")

$dateElements | % `
{
    $global:fileroot = Join-Path $global:fileroot -ChildPath $_
    if (-not (test-path $global:fileroot ))
    {
        mkdir $global:fileroot;    
    }
}

## retrieving all clouds/connections/clusters
$connectionNames = @()
$allProductionClusterNames = Join-Path $scriptsPath -ChildPath "AllProductionClusterNames.tsv"
if (test-path $allProductionClusterNames)
{
    $connectionNames = Get-Content $allProductionClusterNames | % { $_.ToUpperInvariant() }
}
else
{
    $connections = Get-Cloud 
    $connectionNames = $connections | ? { $_.Name -match "PRD"} | ? { $_.Name -notmatch "FCC"} | ? { $_.Name -notmatch "UFC"} | % { $_.Name.ToUpperInvariant() }
}

$connectionNames | Sort -Unique | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@AllProductionFabrics.tsv") -Encoding utf8 


## Retry logic for unresponsive clusters
$retryAttempt = 0
do
{
    ## Sorting all connections into $maxConcurrentScripts groups
    $connectionGroups = @{}
    ForEach ($groupId in 0..$($maxConcurrentScripts - 1))
    {
        $retryGroupId = $retryAttempt * 1000 + $groupId
        $connectionGroups[$retryGroupId] = @()
    }

    $n = 0
    ForEach ($connectionName in $connectionNames) 
    {
        $groupId = $n % $maxConcurrentScripts
        $retryGroupId = $retryAttempt * 1000 + $groupId
        $connectionGroups[$retryGroupId] += $connectionName
        $n += 1
    }

    ## Parallel execution of $maxConcurrentScripts 
    ForEach ($groupId in $connectionGroups.Keys)
    {
        ## Wait if max concurrent tasks are running
        while($ActiveTasks.Count -ge $MaxConcurrentTasks)
        {
            $modelFiles = Get-ChildItem -Path $global:fileroot -Filter "DCM_Microsoft.Windows.Azure.Fabric.DataCenterManager.PhysicalModel.xml" -Recurse -ErrorAction SilentlyContinue
            $modelsReceived = $modelFiles.Count
            Write-Host "... waiting here for a task to complete... $modelsReceived models received."
            sleep -Seconds 10

            ## Remove inactive tasks
            $keys = [int[]]$ActiveTasks.Keys
            foreach($key in $keys)
            {
                $Active = Get-Process -Id $key -ErrorAction SilentlyContinue
                if($Active)
                {
                    continue
                }

                $ActiveTasks.Remove($key)
                Write-Host "Process " $key " Removed" 
            }
        }


        if(($connectionGroups[$groupId]).Length -gt 0)
        {
            $groupIdFormatted = "{0:D4}" -f  $groupId
            $processStdOut = Join-Path $global:fileroot -ChildPath "$groupIdFormatted.stdout.log"

            ## Creating parameters string for the task
            $groupNames = $connectionGroups[$groupId] -join ","
            $parameters = "$script $modulesPath $scriptsPath $global:fileroot $groupId $groupNames *>> $processStdOut"
    
            ## Launch the task
            $startedProcess = [diagnostics.process]::start($executable,$parameters)
    
            $ActiveTasks[$startedProcess.Id] = $startedProcess
            Write-Host "Process " $startedProcess.Id " started for group $groupId : $groupNames"
        }
    }

    ## Wait until all concurrent tasks are finished
    while($ActiveTasks.Count -gt 0)
    {
        $modelFiles = Get-ChildItem -Path $global:fileroot -Filter "DCM_Microsoft.Windows.Azure.Fabric.DataCenterManager.PhysicalModel.xml" -Recurse -ErrorAction SilentlyContinue
        $modelsReceived = $modelFiles.Count
        Write-Host "... waiting here for a task to complete... $modelsReceived models received."
        sleep -Seconds 10

        ## Remove inactive tasks
        $keys = [int[]]$ActiveTasks.Keys
        foreach($key in $keys)
        {
            $Active = Get-Process -Id $key -ErrorAction SilentlyContinue
            if($Active)
            {
                continue
            }

            $ActiveTasks.Remove($key)
            Write-Host "Process " $key " Removed" 
        }
    }    


    ## Find all Group_<retryAttempt>###.EmptyFabrics.tsv files, concatenate and count empty fabrics
    $emptyFabrics = Get-ChildItem -Path $global:fileroot -Filter "Group_$retryAttempt*.EmptyFabrics.tsv"

    $connectionNames = @()
    foreach($emptyFabric in $emptyFabrics)
    {
        Get-Content -Path $emptyFabric.FullName | % { $connectionNames += $_.ToString().ToUpperInvariant() }
    }
     
    
    $retryAttempt += 1
}
until (($retryAttempt -ge 4) -or ($connectionNames.Length -eq 0))

Write-Host "Total unresponsive fabrics" $connectionNames.Length "after" $retryAttempt "attempts."
$connectionNames

$fileGeneratorExecutable = Join-Path $binPath -ChildPath "DcmPhysicalModelFileGenerator.exe"

$datacenterCodeMap = Join-Path $binPath -ChildPath "Data\DcmToAssetDatacenterMapping.xml"

& $fileGeneratorExecutable $global:fileroot,$datacenterCodeMap

if ($LastExitCode -ne 0)
{
    Write-Host "File Generator Failed, no files to upload to azure"
    Exit
}


## Concatenate final results before publishing to Azure
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.Fabric.Log") |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Stats.log") -Encoding utf8 
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.Error.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Error.log") -Encoding utf8 
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.Information.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Information.log") -Encoding utf8 
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.Verbose.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Verbose.log") -Encoding utf8 
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.Warning.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Warning.log") -Encoding utf8 
Get-Content -Path $(Join-Path $global:fileroot -ChildPath "*.stdout.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@Warning.log") -Encoding utf8 
$connectionNames | Sort -Unique | Out-File -FilePath $(Join-Path $global:fileroot -ChildPath "@EmptyFabrics.tsv") -Encoding utf8 

# Azure subscription-specific variables.
$storageAccountName = "assetreconciliationstore"
$containerName = "dcm-uploads"


# Upload files in data subfolder to Azure.
$dataFolder = $global:fileroot
$destfolder = $global:start.Year.ToString("0000") + "-" + $global:start.Month.ToString("00") + "-" + $global:start.day.ToString("00") + "/" + $global:start.Hour.ToString("00")

$storageAccountKey = "oDXZ1PIW/zDaiajhFYWs6frhk3ae7enItX1razln0qk0Oj3SSg6mbnfWzoBbn9D8FBSmwsseqK3QHtGag9KlvA=="
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$files = Get-ChildItem -Path $dataFolder -Filter "@*"
foreach($file in $files)
{
  $fileName = Join-Path $global:fileroot -ChildPath $file
  $destinationFilename = $file -replace "@",""
  $blobName = "$destfolder/$destinationFilename"
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force
} 
write-host "All files in $dataFolder uploaded to $containerName!"
