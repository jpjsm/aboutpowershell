$testfile = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

## open $testfile as a stream
$testfilestream = [System.IO.File]::Open(
    $testfile, 
    [System.IO.FileMode]::Open, 
    [System.IO.FileAccess]::Read) 

$hashFromStream = Get-FileHash -InputStream $testfilestream -Algorithm MD5 

$testfilestream.Close()

$hashFromFile = Get-FileHash -Path $testfile -Algorithm MD5 

## check both hashes are the same
if(($hashFromStream.Hash) -ne ($hashFromFile.Hash)) {
    Write-Error "Get-FileHash results are inconsistent!!" 
}
else {
    Write-Output "Results from File:"
    Write-Output "=================="
    $hashFromFile | Format-List
    Write-Output " "
    Write-Output "Results from Stream:"
    Write-Output "===================="
    $hashFromStream | Format-List
}

