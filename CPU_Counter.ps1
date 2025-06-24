$logical_processors = [System.Environment]::ProcessorCount
get-counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue
    | Select-Object -ExpandProperty CounterSamples 
    | Select-Object -Property InstanceName,CookedValue
    | Where-Object { $_.CookedValue -gt 0 }
    | Where-Object { $_.InstanceName -ne 'idle'}
    | Sort-Object -Property CookedValue -Descending
    | foreach-object { 
        $CpuInfo = [PSCustomObject]@{
            InstanceName = $_.InstanceName
            CpuValue = [math]::Round($_.CookedValue / $logical_processors, 2)
        }
        
        write-output $CpuInfo 
    } 
##    | Format-Table