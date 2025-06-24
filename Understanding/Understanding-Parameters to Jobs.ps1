Remove-Variable -Name job -Force -ErrorAction SilentlyContinue

$JobArguments = @{}

## $jobscript = get-content -Path "C:\Repos\Bitbucket\juanpablo.jofre\powershell\FindFileDuplicates-OneLiner.ps1"
 
$scriptblock = Get-Command "C:\Repos\Bitbucket\juanpablo.jofre\powershell\FindFileDuplicates-OneLiner.ps1" | Select-Object -ExpandProperty ScriptBlock

$argumentlist = @("Hello", "World", 0, 1, $true, $false)

$job = Start-Job -Name "TestJob" -ScriptBlock $scriptblock -ArgumentList $argumentlist

$jobInstanceId = $job.InstanceId
$JobArguments[$jobInstanceId] = $argumentlist

while ((Get-Job -InstanceId $jobInstanceId).State -eq "Running"){
    Write-Warning "Still running"
    Start-Sleep -Milliseconds 50
}

$job
Write-Output $JobArguments[$jobInstanceId]