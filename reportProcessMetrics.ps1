function Get-AllProcessMetrics {
    param(
        [string[]] $ProcessNames = "*"
    )

    Get-Process $ProcessNames | 
        Format-Table @{Label = "NPM(M)"; Expression = { ([int]($_.NPM / 1MB)).ToString("N0") } },
        @{Label = "PM(M)"; Expression = { ([int]($_.PM / 1MB)).ToString("N0") } },
        @{Label = "WS(M)"; Expression = { ([int]($_.WS / 1MB)).ToString("N0") } },
        @{Label = "VM(M)"; Expression = { ([int]($_.VM / 1MB)).ToString("N0") } },
        @{Label = "Total CPU(secs)"; Expression = { if ($_.CPU) { $_.CPU.ToString("N") } } },
        Threads, Id, MachineName, ProcessName, Responding, PriorityClass, BasePriority, ExitCode, ExitTime,  -AutoSize
}