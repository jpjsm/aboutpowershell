# -----------------------------------------------------------------------
# <copyright file="KeyVaultOperations.ps1" company="Microsoft">
#     Copyright (c) Microsoft Corporation.  All rights reserved.
# </copyright>
# -----------------------------------------------------------------------

# Include
. ".\AzureCommonUtils.ps1"

# -----------------------------------------------------------------------
# The PRE-STEP to follow before using this script:
#
# If the Azure account is not added in the first place,
# Please call the following function in ".\AzureCommonUtils.ps1":
#
# Example: AddAzureAccount -subscriptionName 'your subscription name'
# -----------------------------------------------------------------------


# -----------------------------------------------------------------------
# Create a key vault in the default subscription.
# -----------------------------------------------------------------------
function CreateKeyVault(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$resourceGroupName,
        [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$location = 'West US'
    )

    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule

    # Verify if the given resource group is already created.
    $resourceGroup = Get-AzureResourceGroup -Name $resourceGroupName
    
    # Create a new resource group if it does not already exist.
    if($resourceGroup -eq $null){
        New-AzureResourceGroup -Name $resourceGroupName -Location $location
    }

    # Create vault
    return $vault = New-AzureKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Sku premium -Location $location
}

# -----------------------------------------------------------------------
# Set a new secret to a key vault.
# -----------------------------------------------------------------------
function SetSecret(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$secretName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$secretValue
    )
    
    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule

    $secureSecretValue = ConvertTo-SecureString $secretValue -AsPlainText -Force
    $secret = Set-AzureKeyVaultSecret -VaultName $vaultName -Name $secretName -SecretValue $secureSecretValue

    return $secret
}

# -----------------------------------------------------------------------
# Another function that sets a connection string secret using string format.
# -----------------------------------------------------------------------
function SetConnectionStringSecret(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$secretName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$connectionStringFormat,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$accessKey
    )

    if(![string]::IsNullOrEmpty($connectionStringFormat) -and ![string]::IsNullOrEmpty($accessKey)){
        $connectionString = [string]::Format($connectionStringFormat, $accessKey)
        $secret = SetSecret $vaultName $secretName $connectionString  
    }
    else{
        throw "Error: connectionStringFormat or accesskey can NOT be empty."
    }

    return $secret
}

# -----------------------------------------------------------------------
# Set a new Key Vault access policy for a list of AAD applications.
# The default permission to key/secret is 'Get'.
# The acceptable values for $permissionsToKeys are: All, Decrypt, Encrypt, UnwrapKey, WrapKey, Verify, Sign, Get, List, Update, Create, Import, Delete, Backup, Restore.
# The acceptable values for $permissionsToSecrets are: All, Get, List, Delete.
# -----------------------------------------------------------------------
function SetKeyVaultAccessPolicy(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string[]]$applicationNameList,
        [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]        
        [string[]]$permissionsToKeys = @('Get'),
        [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string[]]$permissionsToSecrets = @('Get')       
    )

    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule
    
    foreach($applicationName in $applicationNameList){
        $SvcPrincipals = (Get-AzureADServicePrincipal -SearchString $applicationName)
        if($SvcPrincipals -ne $null){
            $servicePrincipal = $SvcPrincipals[0]
        }
        else{
            throw "Error: the AAD application does not exist."
        }

        Set-AzureKeyVaultAccessPolicy -VaultName $vaultName	-ObjectId $servicePrincipal.Id -PermissionsToKeys $permissionsToKeys -PermissionsToSecrets $permissionsToSecrets
    }
}

# -----------------------------------------------------------------------
# Get the secret value from the key vault.
# -----------------------------------------------------------------------
function GetSecret(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$secretName
    )
    
    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule

    $secret = Get-AzureKeyVaultSecret -VaultName $vaultName -Name $secretName 

    return $secret
}

# -----------------------------------------------------------------------
# Get all secret pairs from the key vault.
# -----------------------------------------------------------------------
function GetSecrets(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$vaultName
    )
    
    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule

    $secrets = Get-AzureKeyVaultSecret -VaultName $vaultName

    return $secrets
}
