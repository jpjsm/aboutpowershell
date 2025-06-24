cd "C:\GIT\JuanPablo.Jofre\PowerShell\KeyVaultOperations"
. ".\KeyVaultOperations.ps1"

AddAzureAccount -subscriptionName 'AssetReservationAllocationGME_ECO'

## Vaults:
## PPE 
$vaultName = "assetreconppevault"

## PROD
## $vaultName = "AssetReconKeyVault"

## Enable access to Key Vault 
Set-AzureKeyVaultAccessPolicy -VaultName $vaultName -UserPrincipalName jpjofre@gme.gbl -PermissionsToKeys all -PermissionsToSecrets all

$ppeSecrets = GetSecrets -VaultName $vaultName

$ppeSecrets

$secret = SetSecret -VaultName $vaultName -secretName "MocaDbConnectionString" -secretValue "Data Source=enfp520tvg.database.windows.net;Initial Catalog=MOCA;Integrated Security=False;User ID=moca_readonly;Password=asset_me(3)"

$secret

$retrievedMocaDbConnection = GetSecret -vaultName $vaultName -secretName "MocaDbConnectionString"

$retrievedMocaDbConnection