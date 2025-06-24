[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)][System.String]$binPath,
[Parameter(Mandatory=$true)][System.String]$resultsPath,
[Parameter(Mandatory=$true)][System.String]$DatacenterMapFile
)


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

$fileGeneratorExecutable = Join-Path $binPath -ChildPath "DcmPhysicalModelFileGenerator.exe"

& $fileGeneratorExecutable $resultsPath $DatacenterMapFile

if ($LastExitCode -ne 0)
{
    Write-Host "File Generator Failed, no files to upload to azure"
    Exit
}


## Concatenate final results before publishing to Azure
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.Fabric.Log") |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Stats.log") -Encoding utf8 
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.Error.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Error.log") -Encoding utf8 
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.Information.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Information.log") -Encoding utf8 
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.Verbose.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Verbose.log") -Encoding utf8 
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.Warning.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Warning.log") -Encoding utf8 
Get-Content -Path $(Join-Path $resultsPath -ChildPath "*.stdout.Log")  |% { $_ -replace "System.Object\[\]", "" } | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@Warning.log") -Encoding utf8 
$connectionNames | Sort -Unique | Out-File -FilePath $(Join-Path $resultsPath -ChildPath "@EmptyFabrics.tsv") -Encoding utf8 

# Azure subscription-specific variables.
$storageAccountName = "assetreconciliationstore"
$containerName = "dcm-uploads"


# Upload files in data subfolder to Azure.
$dataFolder = $resultsPath
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

