
[string]$referenceFolder = "C:\GIT\PowerShell-Docs\reference\"
[string]$prefixRoot = "C:\PowerShell 6 Reference\broken links\Reference-Fixed-"
[string[]]$versions = @("6")

foreach($version in $versions){
    $versionFolder = Join-Path -Path $referenceFolder -ChildPath $version 
    $prefix = $prefixRoot + $version + " "

    Get-BrokenLinksInMdDocuments -DocumentsFolder $versionFolder -BrokenLinkReportPrefix $prefix -fixBrokenLinks -Verbose}
