$onedrive = @("D:\jpjofresm\OneDrive", "D:\juanpablo.jofre\OneDrive")
$videoextensions = @{
".3g2"  = 1
".3gp"  = 1
".amv"  = 1
".asf"  = 1
".avi"  = 1
".drc"  = 1
".f4a"  = 1
".f4b"  = 1
".f4p"  = 1
".f4v"  = 1
".flv"  = 1
".gif"  = 1
".gifv"  = 1
".m2v"  = 1
".m4p"  = 1
".m4v"  = 1
".mkv"  = 1
".mng"  = 1
".mov"  = 1
".mp2"  = 1
".mp4"  = 1
".mpe"  = 1
".mpeg"  = 1
".mpg"  = 1
".mpv"  = 1
".mxf"  = 1
".nsv"  = 1
".ogg"  = 1
".ogv"  = 1
".qt"  = 1
".rm"  = 1
".rmvb"  = 1
".roq"  = 1
".svi"  = 1
".vob"  = 1
".webm"  = 1
".wmv"  = 1
".yuv"  = 1
}

$videos = @{}
$lines = @()
Get-ChildItem -Path $onedrive -Recurse |
    Where-Object { $videoextensions.ContainsKey($_.Extension) } |
    ForEach-Object {
        if (-not $videos.ContainsKey($_.Extension)) {
            $videos.Add($_.Extension, @())
        }
        $videos[$_.Extension] += $_.FullName
    }

$videos.GetEnumerator() | Sort-Object -Property Key |
    ForEach-Object {
        $ext = $_.Key
        $_.Value |
            ForEach-Object {
                $lines += "$ext`t$_"
            }
    }

[System.IO.File]::WriteAllLines("C:\tmp\videosOneDrive.txt", $lines)    