[System.String]$teststring = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcefghijklmnopqrstuvwxyz0123456789"
[byte[]]$testbytes = [System.Text.UnicodeEncoding]::Unicode.GetBytes($teststring)

[System.IO.Stream]$memorystream = [System.IO.MemoryStream]::new($testbytes)
$hashfromstream = Get-FileHash -InputStream $memorystream -Algorithm SHA256
$hashfromstream.Hash