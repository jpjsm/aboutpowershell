# -----------------------------------------------------------------------
# <copyright file="AzureADApplicationHelper.ps1" company="Microsoft">
#     Copyright (c) Microsoft Corporation.  All rights reserved.
# </copyright>
# -----------------------------------------------------------------------

# Include scripts
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
# Add a new Azure Active Directory application with a certificate (.cer file).
# -----------------------------------------------------------------------
function AddNewAzureADApplication(){
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$applicationName,
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]$pathToCer
    )

    # Switch Azure mode to AzureResourceManager if necessary.
    SetAzureResourceManagerModule

    # Prepare the certificate.
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($pathToCer)
    $credValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
    $now = [System.DateTime]::Now
    # Expiration date can NOT be greater than the certificate's expiration date.
    $endDate = $now.AddYears(1)

    # Add each AAD application in the list using the same certificate.
    $appUrl = [string]::Format("http://{0}", $applicationName)
    $AADApp = New-AzureADApplication -DisplayName $applicationName -HomePage $appUrl -IdentifierUris $appUrl -KeyValue $credValue -KeyType "AsymmetricX509Cert" -KeyUsage "Verify" -StartDate $now -EndDate $endDate
    $servicePrincipal = New-AzureADServicePrincipal -ApplicationId $AADApp.ApplicationId 

	return $result = @{ApplicationName=$applicationName}, @{ClientId=$servicePrincipal.ApplicationId}
}