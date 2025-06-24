[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)][System.String]$buddyName,
    [Parameter(Mandatory=$true)][System.Double]$napLengthMinutes,
    [Parameter(Mandatory=$true)][System.Double]$snoozeLengthSeconds
)

Import-Module "C:\GIT\JuanPablo.Jofre\PowerShell\TestFunctions.psm1"

$dozing = [TimeSpan]::FromMinutes($napLengthMinutes)
$snoozing = [TimeSpan]::FromSeconds($snoozeLengthSeconds)
Doze $buddyName $dozing $snoozing