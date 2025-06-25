cd "C:\GIT\JuanPablo.Jofre\PowerShell\KeyVaultOperations"
. ".\KeyVaultOperations.ps1"

$subscriptionName = "AssetReservationAllocationGME_ECO"
$vaultName = "assetreconppevault"

Add-AzureAccount

Select-AzureSubscription -SubscriptionName $subscriptionName

$ppeSecrets = Get-AzureK

## $ppeSecrets = Get-AzureRmKeyVaultSecret -VaultName $vaultName