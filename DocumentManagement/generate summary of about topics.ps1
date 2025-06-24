. "C:\Repos\Bitbucket\juanpablo.jofre\powershell\DocumentManagement\Get-AboutTopicsVersions.ps1"
$versionindex = @{"3.0"=0;"4.0"=1;"5.0"=2;"5.1"=3;"6"=4}
[string[]]$lines = @("About_Topic`t3.0`t4.0`t5.0`t5.1`t6")
Get-AboutTopicsVersions -ReferenceFolder "C:\Repos\GitHub\msft\PowerShell-Docs\reference" |
    Group-Object -Property simplename |
    Sort-Object -Property Name |
    ForEach-Object {
        $topicname = $_.Name
        [string[]]$versions = @("_", "_", "_", "_", "_")
        $_.Group | ForEach-Object {
            $value = $_
            $version = $value.version
            $versions[$versionindex[$_.version]] = 'X'
        }

        $lines += ("$topicname`t" + [string]::join("`t",$versions))
    }

$lines > c:\tmp\about-topics-summary.txt