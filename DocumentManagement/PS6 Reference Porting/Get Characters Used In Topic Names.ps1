$modulesfolder = "C:\tmp\v6"
$usedchars = @{}
Get-ChildItem -Path $modulesfolder -Filter "*.md" -Recurse |
  ForEach-Object {
    ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)).ToLower().ToCharArray() |
      ForEach-Object { $usedchars[$_] += 1 }
  }
  
$usedchars.keys.GetEnumerator() |
  Sort-Object |
  ForEach-Object { 
    $char = $_
    [int]$count = $usedchars[$char]
    Write-Output ("{0,-4}{1,6:N0}" -f $char,$count)
  }