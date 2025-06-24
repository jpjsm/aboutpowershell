$folder = "C:\Users\jpjofre\Pictures"

Get-ChildItem -path $folder -Recurse |
    Group-Object -Property Length |
    Where-Object { $_.Count -gt 1 } |
    ForEach-Object {
        $_.Group | 
            Get-FileHash | 
            Group-Object -Property Hash | 
            Where-Object { $_.Count -gt 1 } |
            ForEach-Object {
                $hash = $_.Name
                $count = $_.Count
                $fileSize = $(Get-Item $_.Group[0].path).Length

                Write-Output "$hash : Files: $count, file size: $fileSize"
                $_.Group | 
                    ForEach-Object {
                        $fileName = $_.Path
                        Write-Output "`t$fileName"
                    }
            }
    }