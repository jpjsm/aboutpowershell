function Get-PS6DocsetStatus{
  [CmdletBinding()]
  param(
    [parameter(Mandatory=$true)] 
    [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]      
    [String]$OutputFolder
  )

  END {  
    [System.IO.File]::WriteAllLines("$OutputFolder\PS6DocsetStatus.tsv", (Get-PS6DocsetStatus), [System.Text.ASCIIEncoding]::ASCII)
  }
}