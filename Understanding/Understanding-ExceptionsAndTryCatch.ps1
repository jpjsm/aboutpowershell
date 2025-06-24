function TestTryCatch
{
    try
    {
        $content = Get-Content -Path "X:\nonexistent.txt" -ErrorAction SilentlyContinue
        Write-Host "After getting non-existing content"
    }
    catch 
    {
        Write-Host "ERROR In function [TestTryCatch]: " 
        Write-Host $($_.Exception.Message)
    }

    $content
}


## $ErrorActionPreference = "stop"

try
{
    TestTryCatch
}
catch
{
    $errMessage = $_.Message
    Write-Error "In main program"
    Write-Error $_.Message

}