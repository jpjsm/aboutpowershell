function Get-OSVersion {
  [string]$osversion = [Environment]::GetEnvironmentVariable("OS")

  if([string]::IsNullOrWhiteSpace($osversion)) {
    ## this is a non-Windows version of PowerShell (at least until PS 6.0)
    $osversion = (lsb_release -d).Split(":")[1].Trim()
  }
  else {
    ## this is a Windows version of PowerShell (at least until PS 6.0)
    $osversion = [Environment]::OSVersion.VersionString
  }

  $osversion
}

function Get-HashValueFromString {
  Param (
    [parameter(Mandatory=$true)] [String] $string    
  )

  [byte[]]$testbytes = [System.Text.UnicodeEncoding]::Unicode.GetBytes($string)

  [System.IO.Stream]$memorystream = [System.IO.MemoryStream]::new($testbytes)
  $hashfromstream = Get-FileHash -InputStream $memorystream -Algorithm SHA256
  $hashfromstream.Hash  
}

Write-Output ([string]::Join("`t", @("osversion", "cmdletmodule", "cmdletname", "cmdlettype", "cmdletvisibility", "cmdletparamsetcount", "cmdletparameterscount", "hashfromparameters")))

[string]$osversion = Get-OSVersion
$cmdlets = @{}

Get-Command |
ForEach-Object {
  [System.Text.StringBuilder]$stringbuilder = [System.Text.StringBuilder]::new(2048)
  $stringbuilder.Append(" ") > $null
  
  [string]$cmdletname = $_.Name
  [string]$cmdletmodule = $_.ModuleName
  [string]$cmdlettype = $_.CommandType
  [string]$cmdletvisibility = $_.Visibility
  [int]$cmdletparamsetcount = $_.ParameterSets.Count
  [int]$cmdletparameterscount = $_.Parameters.Keys.Count
      
  if($cmdletparamsetcount -gt 0) {
    $_.ParameterSets |
    ForEach-Object {
      $stringbuilder.Append($_.Name.ToLowerInvariant()) > $null        
    }
    
  }

  if($cmdletparameterscount -gt 0) {
    $_.Parameters.Keys |
    ForEach-Object {
      $stringbuilder.Append($_.ToLowerInvariant()) > $null              
    }
  }
  
  [string]$hashfromparameters = Get-HashValueFromString -string $stringbuilder.ToString()
      
  Write-Output ([string]::Join("`t", @($osversion, $cmdletmodule, $cmdletname, $cmdlettype, $cmdletvisibility, $cmdletparamsetcount, $cmdletparameterscount, $hashfromparameters)))  
}