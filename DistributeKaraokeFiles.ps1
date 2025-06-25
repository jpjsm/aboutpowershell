function cleanString([string] $str)
{
    return $str.Replace(" ", "").Replace("Á","A").Replace("á","a").Replace("É","E").Replace("é","e").Replace("Í","I").Replace("í","í").Replace("Ó","O").Replace("ó","o").Replace("Ú","U").Replace("ú","u").Replace("Ü","U").Replace("ü","u").Replace("Ñ","GN").Replace("ñ","gn")
}

$PendriveName = "KARAOKE"
$SourceDriveName = "NOSOTROS"
$SourceDriveFolderName = "\Karaoke"

$volumes = Get-Volume -FileSystemLabel $PendriveName
$volumeCount = @($volumes).Count

if($volumeCount -ne 1)
{
    Write-Host "More than 1 drive with expected Karaoke-PenDrive name"
    $volumes
    Throw "More than 1 drive with expected Karaoke-PenDrive name"
}

$pendriveVolume = @($volumes)[0]
$pendriveLetter = $pendriveVolume.DriveLetter

$volumes = Get-Volume -FileSystemLabel $SourceDriveName
$volumeCount = @($volumes).Count

if($volumeCount -ne 1)
{
    Write-Host "More than 1 drive with expected Karaoke-SourceDrive name"
    $volumes
    Throw "More than 1 drive with expected Karaoke-SourceDrive name"
}

$volume = @($volumes)[0]
$sourcedriveLetter = $volume.DriveLetter

$sourcePath = $sourcedriveLetter + ":" + $SourceDriveFolderName
$logFile = $sourcePath + "\KaraokeFiles.txt"
$karaokeFiles = Get-ChildItem -Path $sourcePath -Recurse -File -Include @("*.avi","*.mpg")
$fileCount = @($karaokeFiles).Count
Write-Host "Total karaoke files: " + $fileCount
Format-Volume -DriveLetter $pendriveLetter -Verbose -NewFileSystemLabel $PendriveName
$("Cantante" + "|" + "Canción" + "|" + "NúmeroCanción" + "|" + "Folder" + "|" + "Posición" + "|" + "Archivo") | Out-File -FilePath $logFile

$totalBins = 128
$songsPerBin = $([math]::Truncate($fileCount / $totalBins))
$extraSongsToDistribute = $fileCount % $totalBins
$binNumber = 1
$songNumber = 1
$folderNumber = 1
$indexNumber = 1
foreach($karaokeFile in $($karaokeFiles | sort FullName))
{
    $folderName = cleanString $(Split-Path -Leaf $karaokeFile.DirectoryName)
    $fileName = cleanString $karaokeFile.BaseName
    # =IF(A5<(songsPerBin+1)*extraSongsToDistribute,INT((A5-1)/(songsPerBin+1)),INT((A5-1-extraSongsToDistribute)/songsPerBin))+1
    if($songNumber -lt ($songsPerBin + 1) * $extraSongsToDistribute)
    {
        $folderNumber =[int]($([math]::Truncate(($songNumber - 1)/($songsPerBin + 1)) + 1))
        $indexNumber =[int]((($songNumber - 1) % ($songsPerBin + 1)) + 1)
    }
    else
    {
        $folderNumber =[int]( $([math]::Truncate(($songNumber - 1 - $extraSongsToDistribute)/$songsPerBin) + 1))
        $indexNumber =[int]((($songNumber - 1 - $extraSongsToDistribute) % $songsPerBin) + 1)
    }

    Write-host $songNumber $folderNumber $indexNumber
    $formattedSongNumber = "S" +$("{0:D5}" -f $songNumber)
    $formattedFolderNumber = "F" +$("{0:D3}" -f $folderNumber)
    $formattedIndexNumber = "I" +$("{0:D3}" -f $indexNumber)
    Write-host $($(Split-Path -Leaf $karaokeFile.DirectoryName) + "|" + $karaokeFile.BaseName + "|" + $formattedSongNumber + "|" + $formattedFolderNumber + "." + $formattedIndexNumber + "|" + $folderName + "." + $fileName + $karaokeFile.Extension)
    $destinationPath = $pendriveLetter + ":\" + $formattedFolderNumber + "\" + $formattedIndexNumber + "." + $folderName + "." + $fileName + $karaokeFile.Extension 
    if(!$(Test-Path $($pendriveLetter + ":\" + $formattedFolderNumber)))
    {
        New-Item -ItemType Directory -Path $($pendriveLetter + ":\" + $formattedFolderNumber)
    }

    $($(Split-Path -Leaf $karaokeFile.DirectoryName) + "|" + $karaokeFile.BaseName + "|" + $formattedSongNumber + "|" + $formattedFolderNumber + "|" + $formattedIndexNumber + "|" + $folderName + "." + $fileName + $karaokeFile.Extension) | Out-File -FilePath $logFile -Append

    Copy-Item $karaokeFile.FullName $destinationPath
    $songNumber += 1
}