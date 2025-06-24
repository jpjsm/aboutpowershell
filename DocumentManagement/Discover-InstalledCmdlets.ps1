$cmdletBySource = @{} 
$cmdlets = @{}
Get-Command |
    ForEach-Object {
        [string]$source = $_.Source
        [string]$commandType = $_.CommandType

        if(-not $cmdletBySource.ContainsKey($source)){
            $cmdletBySource.Add($source, @{})
        }

        if(-not $cmdletBySource[$source].ContainsKey($commandType)){
            $cmdletBySource[$source].Add($commandType, @())
        }

        $cmdletBySource[$source][$commandType] += $_.Name
        $cmdlets.Add($_.Name, $_)
    }

[int]$totalSourceInstalled = $cmdletBySource.Keys.Count
[int]$totalAliases = 0
[int]$totalFunctions = 0
[int]$totalCmdlets = 0
[int]$totalCmds = 0

[string] $rowFormat = "{0,-60} {1,10:N0} {2,10:N0} {3,10:N0} {4,10:N0}"
Write-Output "Total different sources: $totalSourceInstalled"
Write-Output " "
Write-Output "=============================================="
Write-Output " "
Write-Output " "
Write-Output $($rowFormat -f "Source", "Alias", "Function", "Cmdlet", "Total")
Write-Output $($rowFormat -f "------", "-----", "--------", "------", "-----")


$cmdletBySource.Keys | 
    Sort-Object  |
    ForEach-Object {
        [string]$source = $_

        [int]$aliases = $cmdletBySource[$source]["Alias"].Count
        [int]$functions = $cmdletBySource[$source]["Function"].Count
        [int]$cmdlets = $cmdletBySource[$source]["Cmdlet"].Count
        [int]$totalRow = $aliases + $functions + $cmdlets

        $totalAliases += $aliases
        $totalFunctions += $functions
        $totalCmdlets += $cmdlets
        $totalCmds += $totalRow

        if([System.String]::IsNullOrWhiteSpace($_)){
            $source = "<un-named>"
        }

        Write-Output $($rowFormat -f $source, $aliases, $functions, $cmdlets, $totalRow )
    }

Write-Output $($rowFormat -f "------", "-----", "--------", "------", "-----")
Write-Output $($rowFormat -f "[Total]", $totalAliases, $totalFunctions, $totalCmdlets, $totalCmds )
Write-Output "=============================================="
Write-Output " "
Write-Output " "

$cmdletBySource.Keys | 
    Sort-Object  |
    ForEach-Object {
        [string]$source = $_

        [int]$aliases = $cmdletBySource[$source]["Alias"].Count
        [int]$functions = $cmdletBySource[$source]["Function"].Count
        [int]$cmdlets = $cmdletBySource[$source]["Cmdlet"].Count
        
        [string]$cmdletsource = $source
        if([System.String]::IsNullOrWhiteSpace($cmdletsource)){
            $cmdletsource = "<un-named>"
        }

        Write-Output ("   " + $cmdletsource)
        Write-Output ("   " + ([string]::new("-", $cmdletsource.Length)))

        if($aliases -gt 0) {
            Write-Output "      Alias"
            Write-Output "      ....."
            $cmdletBySource[$source]["Alias"] |
                Sort-Object |
                ForEach-Object {
                    Write-Output ("         " + $_)
                }
            }

        if($cmdlets -gt 0) {
            Write-Output "      Cmdlet"
            Write-Output "      ......"
            $cmdletBySource[$source]["Cmdlet"] |
                Sort-Object |
                ForEach-Object {
                    Write-Output ("         " + $_)
                }
            }

        if($functions -gt 0) {
            Write-Output "      Function"
            Write-Output "      ........"
            $cmdletBySource[$source]["Function"] |
                Sort-Object |
                ForEach-Object {
                    Write-Output ("         " + $_)
                }

        }
    }