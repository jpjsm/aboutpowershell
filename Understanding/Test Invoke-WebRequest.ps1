
$links = @("https://technet.microsoft.com/en-us/library/f00b00m00", "https://technet.microsoft.com/en-us/library/c134aa32-b085-4656-9a89-955d8ff768d0")
$links | % {
    $r = $null;
    ($r = Invoke-WebRequest -URI "$_" -MaximumRedirection 5 -WarningAction SilentlyContinue  -ErrorAction SilentlyContinue -errorvariable ignoreerror) 2>$null 1>$null
    Write-Output $("{1,4} {0}" -f $_, $r.StatusCode)
}