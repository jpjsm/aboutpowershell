$azureResourceManager = Get-Module -Name AzureResourceManager
$azureResourceManager.Name

IF ($azureResourceManager -eq $null)
{
    Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\AzureResourceManager.psd1"
}

$kvSecret = Get-AzureKeyVaultSecret -VaultName WebAppScan -Name SvcVScan -ErrorAction SilentlyContinue
If ($kvSecret -ne $null)
{
    Write-Output $kvSecret.SecretValueText
}
else
{      
    $kvSecret = Get-AzureKeyVaultSecret -VaultName WebAppScan2 -Name SvcVScan -ErrorAction SilentlyContinue
    If ($kvSecret -ne $null)
   {
        Write-Output $kvSecret.SecretValueText
    }
    else
    {
        Write-Output "Secret not available or no access given to Keyvault"
    }
} 
