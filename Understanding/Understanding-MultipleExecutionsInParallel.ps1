## This example starts multiple powershell executables concurrently
##
## Throttling enabled
##

$TasksToExecute = 200
$MaxConcurrentTasks = 10
 
$ActiveTasks = @{}



foreach($buddy in 1..$TasksToExecute)
{

    ## Wait if all concurrent tasks are running
    while($ActiveTasks.Count -ge $MaxConcurrentTasks)
    {
        Write-Host "... waiting here ..."
        sleep -Seconds 10

        ## Remove inactive tasks
        $keys = [int[]]$ActiveTasks.Keys
        foreach($key in $keys)
        {
            $Active = Get-Process -Id $key -ErrorAction SilentlyContinue
            if($Active)
            {
                continue
            }

            $ActiveTasks.Remove($key)
            Write-Host "Process " $key " Removed" 
        }
    }



    ## Assigning variable name and runtime to the task
    $buddyName = "Buddy_" + $buddy.ToString("00")
    [double]$minutes = Get-Random -Minimum 1 -Maximum 3
    [double]$seconds = Get-Random -Minimum 15 -Maximum 30

    ## Launch the task
    $startedProcess = [diagnostics.process]::start("powershell.exe","C:\GIT\JuanPablo.Jofre\PowerShell\UnderstandingScriptArguments.ps1 $buddyName $minutes $seconds")
    
    $ActiveTasks[$startedProcess.Id] = $startedProcess
    Write-Host "Process " $startedProcess.Id " started"
}

