## Install-Module platyPS -Scope CurrentUser -Force
Import-Module platyPS

[string]$version= "v5.0"

[string]$source = "\\wpshelpserver\Content\Core\" + $version
[string]$destination = "C:\PSReferenceMigration\" + $version
[string]$helpversion = $version.Substring(1)
[string]$executionDate = [datetime]::Now.ToString(".yyyy-MM-dd HHmm")
[string]$logfile = "C:\PSReferenceMigration\" + $version + $executionDate + ".log.txt"
[string]$warningfile = "C:\PSReferenceMigration\" + $version + $executionDate + ".warning.txt"
[string]$errorfile = "C:\PSReferenceMigration\" + $version + $executionDate + ".errors.txt"
[string]$verbosefile = "C:\PSReferenceMigration\" + $version + $executionDate + ".verbose.txt"

Generate-PSCoreNewMDsFromModuleMAML `
    -PSCoreMamlSourceFolder $source `
    -PSCoreMDDestinationFolder $destination `
    -HelpVersion $helpversion `
    -WithModulePage -Force -Verbose 1>$logfile 2>$errorfile 3>$warningfile 4>$verbosefile
