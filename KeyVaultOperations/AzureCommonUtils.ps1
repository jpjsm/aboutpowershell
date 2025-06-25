# -----------------------------------------------------------------------
# Add Azure account when it is first started.
# -----------------------------------------------------------------------
function AddAzureAccount(){
    param(  
        [string]$subscriptionName = [String]::Empty        
    )

    Add-AzureAccount
    if(![string]::IsNullOrEmpty($subscriptionName)){
        Select-AzureSubscription -SubscriptionName $subscriptionName
    }
}

# -----------------------------------------------------------------------
# Switch Azure mode to AzureResourceManager.
# -----------------------------------------------------------------------
function SetAzureResourceManagerModule(){
    $currentModule = Get-Module
    if($currentModule -ne $null){
        if($currentModule.Name[0] -ne 'AzureResourceManager'){
            Switch-AzureMode AzureResourceManager
        }
    }
    else{
        Switch-AzureMode AzureResourceManager
    }
}