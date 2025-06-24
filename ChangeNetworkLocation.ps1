#Static variables definition (never change them)
$TrustedNetwork=1
$PublicNetwork=3
 
# Get network connections
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

$CurrentVerbosePreference = $VerbosePreference
$VerbosePreference = 'continue'

$connections | 
    ForEach-Object {
        $network = $_.GetNetwork()
        $networkName = $network.GetName()
        $networkCategory = $network.GetCategory()
        $networkCategoryDescription = [string]::Empty

        switch ($networkCategory)
        {
            (0) { $networkCategoryDescription = "Unidentified" }
            (1) { $networkCategoryDescription = "Trusted" }
            (2) { $networkCategoryDescription = "Domain-Joined" }
            (3) { $networkCategoryDescription = "Public" }
            default { $networkCategoryDescription = "Unknown" }
        }

        Write-Verbose "$networkName : $networkCategory -> $networkCategoryDescription"

        if($networkCategory -ne 1 -and $networkCategory -ne 2) {
            $_.GetNetwork().SetCategory(1)
            [string]$filler = " " * $networkName.Length

            $networkCategory = $network.GetCategory()
            $networkCategoryDescription = [string]::Empty

            switch ($networkCategory)
            {
                (1) { $networkCategoryDescription = "Trusted" }
                (2) { $networkCategoryDescription = "Domain-Joined" }
                (3) { $networkCategoryDescription = "Public" }
                default { $networkCategoryDescription = "Unknown" }
            }

            Write-Verbose "$filler   $networkCategory -> $networkCategoryDescription"
        }
    }

$VerbosePreference = $CurrentVerbosePreference
