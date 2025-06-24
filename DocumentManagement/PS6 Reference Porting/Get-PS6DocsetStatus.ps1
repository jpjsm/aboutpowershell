function Get-PS6DocsetStatus{
  [CmdletBinding()]
  param(  )


  END{
    [string[]]$lines = @()
    
    if(-not $Global:ps6docset) {
      return $lines
    }
    
    $Global:ps6docset.Keys | Sort-Object |
    ForEach-Object {
      [string]$ModuleName = $_
      $Global:ps6docset[$ModuleName].Keys | Sort-Object |
      ForEach-Object {
        [string]$CmdletName = $_
        [string]$DocStatus = $Global:ps6docset[$ModuleName][$CmdletName]
        $lines += [string]::Join("`t",$ModuleName,$CmdletName,$DocStatus)
        Write-Progress ("{0,-40} {1,-50} {2}" -f $ModuleName,$CmdletName,$DocStatus)
      }
    }
    
    $lines
  }
}