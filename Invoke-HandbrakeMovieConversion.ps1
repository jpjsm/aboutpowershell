$HandbrakeLocation = "C:\Program Files\Handbrake"
$HandbrakeCli = "HandbrakeCli.exe"

$ConversionLogsFolder = "D:\MediaConversion-Logs"
$ConversionFolder = "D:\MediaConversion"


if(-not [System.IO.Directory]::Exists($ConversionLogsFolder)) {
    [System.IO.Directory]::CreateDirectory($ConversionLogsFolder)
}


## Script begins here 
$movies = @{}

Get-ChildItem -Path "H:\" -Filter "Pelicula*"|
    Where-Object { $_.PSIsContainer } |
    ForEach-Object {
        Get-ChildItem -Path ($_.FullName) -Recurse |
            Where-Object {(-not $_.PSIsContainer) -and 
                          (   ($_.Extension -eq ".iso") -or 
                              ($_.Extension -eq ".wmv") -or
                              ($_.Extension -eq ".avi") -or
                              ($_.Extension -eq ".mpg")
                          ) } |
            ## Where-Object { $_.FullName -like "*Peliculas DVD - 001\*"} | ## Filter here for testing purposes
            ForEach-Object {
                $movies.Add($_.BaseName, @{
                        "folder" = $_.DirectoryName
                        "type" = ($_.Extension).Substring(1)
                    })
            }
    }

$movies.GetEnumerator() |
    ForEach-Object {
        $ConvertionDateTime = [DateTime]::Now.ToString("yyyy-MM-dd HHmmss")
        [string]$movie = $_.Key
        [string]$type = $_.Value["type"]
        $MovieSourceFolder = $_.Value["folder"]
        $MovieTargetFolder = [System.IO.Path]::Combine($ConversionFolder, $movie)
        $MovieLogFileName = Join-Path -Path $ConversionLogsFolder -ChildPath ($ConvertionDateTime + "-"  + $movie + ".scan.log")

        if(-not [System.IO.Directory]::Exists($MovieTargetFolder)) {
             $null = [System.IO.Directory]::CreateDirectory($MovieTargetFolder) 
        }

        if($type -ne "iso") {
            Get-ChildItem -Path $MovieSourceFolder |
            Where-Object { ($_.Extension -ne ".ini") -and ($_.Extension-ne ".db") } |
            ForEach-Object {
                Write-Progress "[$type] $movie"
                Write-Progress ("File: " + ($_.Name))
                Copy-Item $_.FullName $MovieTargetFolder -Force >> $MovieLogFileName
            }
        }
        else {
            $isopath = Join-Path -Path $MovieSourceFolder -ChildPath ($movie + ".iso")

            $movieinfo=  Get-Item -Path $isopath
            [string]$handbrakeInputArgument = [string]::Empty
            [string]$mntDrive = [string]::Empty
            $mntVolume = $null
            [bool]$IsBlueDisk = $false
            if($movieinfo.Length -gt 10GB) {
                Mount-DiskImage -ImagePath $isopath
                $mntVolume = Get-DiskImage -ImagePath $isopath | Get-Volume
                [string]$mntDrive = "{0}:\" -f ($mntVolume.DriveLetter) 
                $handbrakeInputArgument = "--input $mntDrive"
                $IsBlueDisk = $true
            }
            else {
                $handbrakeInputArgument = "--input `"$isopath`""
            }

            [string]$handbrakeScanArguments =$handbrakeInputArgument + " --scan --main-feature"


            $process = New-Object -TypeName System.Diagnostics.Process
            $process.StartInfo.FileName = Join-Path -Path $HandbrakeLocation -ChildPath $HandbrakeCli
            $process.StartInfo.Arguments = $handbrakeScanArguments
            $process.StartInfo.WorkingDirectory = $HandbrakeLocation
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.RedirectStandardOutput = $true
            $process.StartInfo.RedirectStandardError = $true

            $started = $process.Start()

            [string]$ScanErrStreamText = $process.StandardError.ReadToEnd()
            [string]$ScanStdoutStreamText = $process.StandardOutput.ReadToEnd()
            Write-Progress "Searching for main title: [$type] $movie" 

            $process.WaitForExit()
            $exitcode = $process.ExitCode
            [System.IO.File]::WriteAllText($MovieLogFileName, $ScanErrStreamText, [System.Text.UnicodeEncoding]::Unicode)

            if($exitcode -eq 0) {
                $strReader = [System.IO.StringReader]::new($ScanErrStreamText)

                ## skip scan log detail
                [string]$line = $null

                do { $line = $strReader.ReadLine() } 
                until (($line -eq $null) -or ($line -like "Found main feature title, setting title to *"))
                
                if($line) {
                    ## main title found !!
                    Write-Progress $line 
                    [int]$skiptext = "Found main feature title, setting title to".Length
                    [int]$MainTitleIndex = [int]::Parse($line.Substring($skiptext).Trim())

                    ## ToDo: Copy miscellaneous files from source folder

                    ## Update arguments to generate output

                    [string]$MkvMoviePath = [System.IO.Path]::Combine($MovieTargetFolder, $movie + ".mkv")
                    [string]$quality = "20.0"
                    if($IsBlueDisk){
                        $quality = "26.0"
                    }
                    [string]$handbrakeMovieArguments = ("{0} --title {1} --format av_mkv --output `"{2}`" --markers --encoder x264 --quality {3} --all-audio --aencoder av_aac --all-subtitles " -f $handbrakeInputArgument,$MainTitleIndex,$MkvMoviePath,$quality )
                    
                    ## Generate MKV file 
                    $process = New-Object -TypeName System.Diagnostics.Process
                    $process.StartInfo.FileName = Join-Path -Path $HandbrakeLocation -ChildPath $HandbrakeCli
                    $process.StartInfo.Arguments = $handbrakeMovieArguments
                    $process.StartInfo.WorkingDirectory = $HandbrakeLocation
                    $process.StartInfo.UseShellExecute = $false
                    $process.StartInfo.RedirectStandardOutput = $true
                    $process.StartInfo.RedirectStandardError = $true

                    $started = $process.Start()

                    [string]$ScanErrStreamText = $process.StandardError.ReadToEnd()
                    [string]$ScanStdoutStreamText = $process.StandardOutput.ReadToEnd()
                    Write-Progress "Searching for main title: [$type] $movie" 

                    $process.WaitForExit()
                    $MovieLogFileName = Join-Path -Path $ConversionLogsFolder -ChildPath ($ConvertionDateTime + "-"  + $movie + ".encoding.log")
                    [System.IO.File]::WriteAllText($MovieLogFileName, $ScanErrStreamText, [System.Text.UnicodeEncoding]::Unicode)

                }
                else {
                    [System.IO.File]::WriteAllText(($conversionLogFileName+".err"), "No main feature found!!", [System.Text.UnicodeEncoding]::Unicode)
                }


                $strReader.Close(); $strReader.Dispose()
            }

            if($mntVolume) {
                Dismount-DiskImage -ImagePath $isopath
            }
        }
    }