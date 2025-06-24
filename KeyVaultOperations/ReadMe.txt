------------------------------------------------------------------
This Readme.txt explains how to use the KeyVaultHelper library.
------------------------------------------------------------------

Before being able to access the secret stored in Azure Key Vault using "KeyVaultSecretAccessor.cs", you need to set up a few things. 
The PowerShell scripts stored under the "Scripts" folder help to do so.

The following instructions will walk you through the process from end to end in different scenarios. In the first place, please add the Azure
account using "AddAzureAccount" function in "AzureCommonUtils.ps1" before running "AzureADApplicationHelper.ps1" or "KeyVaultOperations.ps1":

	AddAzureAccount -subscriptionName 'your target subscription name'


1. Application administrator:
	Using "AzureADApplicationHelper.ps1"... This script is referencing "AzureCommonUtils.ps1".

	a) Add a new Azure Active Directory application with a certificate (.cer file) for your cloud service:

		$appServicePrincipal = AddNewAzureADApplication -applicationName 'app1name' -pathToCer 'C:\Users\user\somewhere\certname.cer'
		$clientId = $appServicePrincipal.ClientId

2. Key Vault administrator:
	Using "KeyVaultOperations.ps1"... This script is referencing "AzureCommonUtils.ps1".
	
	a) Create a new Key Vault:
		
		$vault = CreateKeyVault -vaultName 'KeyVaultName' -resourceGroupName 'ResourceGroupName' -location 'West US'

	b) Set a new secret to the key vault:
		
		*** Use "SetSecret" function and pass the secret value as a whole:

		$secret = SetSecret -vaultName 'keyVaultName' -secretName 'SecretName' -secretValue 'SecretValue'

		*** OR use "SetConnectionStringSecret" function if the secret value is a connection string. This function helps to set
		a connection string secret using string format.

		$secret = SetConnectionStringSecret -vaultName 'KeyVaultName' -secretName 'ServiceBusConnStrName' 
								-connectionStringFormat 'Endpoint=sb://yourservicebus.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey={0}'
								-accessKey '1CoMDJAzmdGHX/Rzrq9ScCizT/IYhyoY++n84Ib6mxk='

	c) Set a new Key Vault access policy for a list of AAD applications:
		*** The default permission to key/secret is 'Get'.
		*** The acceptable values for $permissionsToKeys are: All, Decrypt, Encrypt, UnwrapKey, WrapKey, Verify, Sign, Get, List, Update, Create, Import, Delete, Backup, Restore.
		*** The acceptable values for $permissionsToSecrets are: All, Get, List, Delete.

		SetKeyVaultAccessPolicy -vaultName 'KeyVaultName' -applicationNameList app1name, app2name, app3name
								-permissionsToKeys ALL -permissionsToSecrets Get, List

3. Application:
	Using "KeyVaultSecretAccessor.cs"... with AAD application ClientId and the thumbprint of the certificate for authentication

	a) Get secret from Key Vault:

		*** If you have Key Vault address and secret name:

			var secretValue = KeyVaultSecretAccessor.GetSecret(keyVaultAddress, secretName, clientId, thumbprint);

		*** If you have the secret identifier (url):

		    var secretValue = KeyVaultSecretAccessor.GetSecret(secretIdentifier, clientId, thumbprint);