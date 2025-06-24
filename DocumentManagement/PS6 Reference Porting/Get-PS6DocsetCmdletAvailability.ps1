function Get-PS6DocsetCmdletAvailability{
  [CmdletBinding()]
  param( )

  END {
    [string[]]$lines = @()
    
    if(-not $Global:ModuleCmdletDict) {
      return $lines
    }
    
    $Global:ModuleCmdletDict.GetEnumerator() |
    ForEach-Object {
      [string]$ModuleName = $_.Key
      [string]$ModuleDisplayName = $Global:ModuleNameDict[$_.Key]["DisplayName"]
      $_.Value.GetEnumerator() |
      ForEach-Object {
        [string]$CmdletName = $_.Key
        [string[]]$platforms = @($Global:ModuleCmdletDict[$ModuleName][$CmdletName]["Availability"].Keys | ForEach-Object { $_.ToString() })
        [string]$CmdletAvailability = [string]::Join(",", @( $Global:ModuleCmdletDict[$ModuleName][$CmdletName]["Availability"].Keys | Sort-Object))
        [string]$CmdletDisplayName = @($Global:ModuleCmdletDict[$ModuleName][$CmdletName]["Availability"].Values)[0]
      
        $line = "$ModuleDisplayName`t$CmdletDisplayName`t$CmdletAvailability"
        $lines += $line
        Write-Progress $line
      }
    }
  
    $lines
  }
}