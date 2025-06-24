. "C:\GIT\juanpablo.jofre@bitbucket.org\powershell\Build-CmdletReferenceInfo.ps1"

function Get-CmdletModuleInfo{
  Build-CmdletReferenceInfo -datafolder "C:\PowerShell 6 Reference\InstalledCmdletParameterInfo"
  
  ## Checking total diferent OS versions
  [int]$TotalDifferentOS = $Global:OsVersions.Count
  Write-Output "Different OSes found in data: $TotalDifferentOS"
  $Global:OsVersions.Keys |
  Sort |
  ForEach-Object { Write-Output "`t$_"}

  Write-Output " "
  Write-Output "---------------------------------------------------------------------------"
  Write-Output " "

  ## Checking Modules not in all OSes
  Write-Output "List of Modules not in all OSes"
  $Global:ModuleNameDict.Keys |
  Where-Object {$Global:ModuleNameDict[$_]["Availability"].Count -lt $TotalDifferentOS} | 
  Sort |
  ForEach-Object {
    [string]$modulename = $_
    [string[]]$currentoses = $Global:ModuleNameDict[$modulename]["Availability"].Keys.GetEnumerator() | ForEach-Object { $_ }
    [string]$currentavailability = [string]::Join(", ", $currentoses)
    Write-Output "`t$modulename : $currentavailability"
  }

  Write-Output " "
  Write-Output "---------------------------------------------------------------------------"
  Write-Output " "

  ## Checking Cmdlets not in all OSes
  $CmdletsNotInAllOs = @{}
  Write-Output "List of Cmdlets not in all OSes"
  $Global:ModuleCmdletDict.Keys |
  Sort |
  ForEach-Object {
    [string]$cmdletmodule =  $_
    $Global:ModuleCmdletDict[$cmdletmodule].Keys |
    Where-Object {$Global:ModuleCmdletDict[$cmdletmodule][$_]["Availability"].Count -lt $TotalDifferentOS} |
    Sort |
    ForEach-Object {
      Write-Output "`t$cmdletmodule.$_"
      $CmdletsNotInAllOs.Add($cmdletmodule +"." + $_, $true)
    }
  }

  Write-Output " "
  Write-Output "---------------------------------------------------------------------------"
  Write-Output " "

  ## Checking Paramters not in all the OSes where the cmdlet is available
  ##  Where-Object {$Global:ModuleCmdletDict[$cmdletmodule][$_]["Availability"].Count -eq $TotalDifferentOS} |
  Write-Output "List of Parameters not in all the OSes where the cmdlet is available"
  $Global:ModuleCmdletDict.Keys |
  Sort |
  ForEach-Object {
    [string]$cmdletmodule =  $_
    $Global:ModuleCmdletDict[$cmdletmodule].Keys |
    Sort |
    ForEach-Object {
      [string]$cmdletname = $_
      [int]$cmdletavailability = $Global:ModuleCmdletDict[$cmdletmodule][$cmdletname]["Availability"].Count
      $Global:ModuleCmdletDict[$cmdletmodule][$cmdletname]["Parameters"].Keys |
      Where-Object {$Global:ModuleCmdletDict[$cmdletmodule][$cmdletname]["Parameters"][$_].Count -lt $cmdletavailability} |
      ForEach-Object{
        Write-Output "`t$cmdletmodule`'$cmdletname`'$_"
      }
    }
  }


  Write-Output " "
  Write-Output "---------------------------------------------------------------------------"
  Write-Output " "

  
  
}