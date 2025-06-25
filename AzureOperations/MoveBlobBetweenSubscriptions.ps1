# Azure source
$storageAccountName = "assetreconciliationstore"
$storageAccountKey = "oDXZ1PIW/zDaiajhFYWs6frhk3ae7enItX1razln0qk0Oj3SSg6mbnfWzoBbn9D8FBSmwsseqK3QHtGag9KlvA=="
$containerName = "inventory"

# Download files in local data subfolder
$DestinationFolder = "C:\DCM-Uploads\$containerName"

$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$blobReferences = Get-AzureStorageBlob -Container $containerName -Blob "*/2015/12/01/*" -Context $blobContext 

$blobReferences | Get-AzureStorageBlobContent –Destination $DestinationFolder -Force

# Azure destination
$storageAccountName = "assetrecouncilerppestore"
$storageAccountKey = "ayVArBnVTbz5C7r1xhpoaj/6iaI4KSpceEiM+sMa3oZYXTIArndjK6i2WAaHFJwv3JUWl6qVdTRcziANvG9+SQ=="

$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$files = Get-ChildItem -Path $DestinationFolder -Recurse | ? { ! $_.PSIsContainer }

foreach($file in $files)
{
  $fileName = $file.FullName
  $blobName = $fileName.Substring($DestinationFolder.Length + 1).Replace('\','/')
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force
} 
write-host "All files in $DestinationFolder uploaded to $containerName !"
