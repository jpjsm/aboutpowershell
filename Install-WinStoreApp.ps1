Get-AppXPackage -AllUsers *LastPass* | 
    ForEach-Object {
        $installLocation = $_.InstallLocation
        Add-AppxPackage -Path ("$installLocation\AppXManifest.xml")  -DisableDevelopmentMode -Register 
    }