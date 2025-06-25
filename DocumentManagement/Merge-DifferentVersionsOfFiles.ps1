[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$filesToMergeList = "C:\PSReferenceConversion\Merge\differences.tsv"
)


function Get-FilesToMerge {
    Param(
        [parameter(Mandatory=$true)][string]$filesToMergeList
    )

    [string[]]$lines = [System.IO.File]::ReadAllLines($filesToMergeList)
    $lines |
        ForEach-Object {
            [string[]]$items = $_.Split("`t")
            $Global:FilesToMerge[$items[0]] = @{ 
                                                "source" = $items[1];
                                                "merge" = $items[2];
                                                "status" = $items[3];
                                                "updated" = $items[4];
                                                }
        }
}

function Update-FilesToMerge {
    Param(
        [parameter(Mandatory=$true)][string]$filesToMergeList
    )

    [string[]]$lines = @()
    $Global:FilesToMerge.GetEnumerator() |
        ForEach-Object {
            $lines += $Global:fileContentPattern -f $_.Key, $_.Value["source"], $_.Value["merge"], $_.Value["status"], $_.Value["updated"]
        }

    [System.IO.File]::WriteAllLines($filesToMergeList, ($lines | Sort-Object -Descending), [System.Text.Encoding]::Unicode)
}


#
## Global definitions
#
$Global:FilesToMerge = @{}
[string]$Global:fileContentPattern = "{0}`t{1}`t{2}`t{3}`t{4}" ## $fileToMerge,$sourceFolder,$comparedFolder,$status,$lastUpdate
$pending = "Pending"
$diffingApp = "C:\Program Files\KDiff3\kdiff3.exe"
$diffingAppArgumentPattern = "{0} {1} -o {2}"

#
## Main: merge files
#
Get-FilesToMerge $filesToMergeList

[string[]]$filesToWork = $Global:FilesToMerge.GetEnumerator() |
    Where-Object { $_.Value["status"] -eq $pending } |
    ForEach-Object { $_.Key } |
    Sort-Object -Descending

foreach($currentFileName in $filesToWork) {
    $currentInfo = $Global:FilesToMerge[$currentFileName]
    [string]$basefile = [System.IO.Path]::Combine($currentInfo["source"], $currentFileName)
    [string]$mergefile = [System.IO.Path]::Combine($currentInfo["merge"], $currentFileName)
    [string]$params = $diffingAppArgumentPattern -f $basefile, $mergefile, $basefile

    $process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo.FileName = $diffingApp
    $process.StartInfo.Arguments = $diffingAppArgumentPattern -f $basefile, $mergefile, $basefile
    $started = $process.Start()
    $process.WaitForExit()
    $errcode = $process.ExitCode
    if($errcode -eq 0){
        $currentInfo["status"] = "Merged"
        $currentInfo["updated"] = "UTC: " + [datetime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss")
        Update-FilesToMerge -filesToMergeList $filesToMergeList
    }

    $finish = Read-Host -Prompt "To finish merging files press: F <Enter>"
    if($finish -eq "F"){
        break
    }
}
