function Write-PS6DocsetCmdletAvailability{
  [CmdletBinding()]
  param(
    [parameter(Mandatory=$true)] 
    [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]      
    [String]$OutputFolder
  )

  END {  
    [System.IO.File]::WriteAllLines("$OutputFolder\PS6DocsetCmdletAvailability.tsv", (Get-PS6DocsetCmdletAvailability), [System.Text.ASCIIEncoding]::ASCII)
  }
}