$referenceFolder = "C:\GIT\PowerShell-Docs\reference"
$oldText = "[!INCLUDE[win8_server_2](../Token/win8_server_2_md.md)]"
$newText = "`'Windows Server 2012®`'"

Get-ChildItem -Path $referenceFolder -Filter *.md -Recurse |
    Select-String -SimpleMatch $oldText |
    Select-Object -Property Path |
    Get-Unique -AsString |
    ForEach-Object {
        $docPath = $_.Path
        Write-Host "Starting to fix: $docPath ..."
        [string]$content = [System.IO.File]::ReadAllText($docPath)
        [System.IO.File]::WriteAllText($docPath,$content.Replace($oldText,$newText), [System.Text.UTF8Encoding]::UTF8)
        Write-Host "Fixed: $docPath !!"
    }
