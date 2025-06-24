$file_path = "C:\FCM\EngSys-CAS-EventRouter\src\owners.txt"
$root_folder = "C:\FCM\EngSys-CAS-EventRouter"
Get-ChildItem -Path $root_folder -Recurse
    | Where-Object { $_.PSIsContainer }
    | ForEach-Object {
        Write-Output $_.FullName
    }