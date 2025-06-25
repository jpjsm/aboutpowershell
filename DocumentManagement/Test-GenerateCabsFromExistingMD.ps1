$rootSourceFolder = "C:\GIT\PowerShell-Docs\reference"
$versions = @("3.0","4.0","5.0")

$rootOutFolder = "C:\tmp\cabbing"

$versions |
    ForEach-Object {
        $currentVersion = [System.IO.Path]::Combine($rootSourceFolder,$_)
        $versionOutFolder = [System.IO.Path]::Combine($rootOutFolder,$_)
        Generate-CabsFromExistingMd -versionFolder $currentVersion -outputfolder $versionOutFolder -Verbose
    }