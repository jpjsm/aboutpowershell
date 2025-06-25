# Azure subscription-specific variables.
$storageAccountName = "assetreconciliationstore"
$containerName = "dcm-processed"

# Upload files in data subfolder to Azure.
$DestinationFolder = "C:\DCM-Uploads\DcmProcessed"

$storageAccountKey = "oDXZ1PIW/zDaiajhFYWs6frhk3ae7enItX1razln0qk0Oj3SSg6mbnfWzoBbn9D8FBSmwsseqK3QHtGag9KlvA=="
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$blobReferences = Get-AzureStorageBlob -Container $containerName -Blob "2015/11/09/04/*" -Context $blobContext 

$blobReferences | Get-AzureStorageBlobContent –Destination $DestinationFolder