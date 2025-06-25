function Update-PS6DocsetPlatformAvailability{
  [CmdletBinding()]
  param(
    [parameter(Mandatory=$true)] 
    [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]      
    [String]$DocsetFolder
  )

  [string[]]$lines = Get-PS6DocsetCmdletAvailability
  
  $lines |
  ForEach-Object {
    [string[]]$DocInfo = $_.Split("`t")
    [string]$ModuleName = $DocInfo[0]
    [string]$CmdletName = $DocInfo[1]
    [string]$PlatformAvailability = $DocInfo[2]
    
    
    ## If Find document
    ##    Check for **Platform Availability:**
    ##    True: Replace ()
    ##    False: Add line before ## SYNTAX'
  }
}