param (
    [ValidateScript({ Test-Path -Path $_ -PathType container }, ErrorMessage = 'Not a valid path: {0}' )]
    [Parameter(Mandatory = $true)]
    [string] $Folder = '.'
)

$filetypes = @{};
$start = (Get-Date)
$counter = 0
Write-Progress -Activity 'Get File-Extension Summary' -Status 'In progress' -PercentComplete 0
$filecount = (get-childitem -Path $Folder -recurse -file | Measure-Object).Count
get-childitem -Path $Folder -recurse -file | 
    foreach-object { 
        $ext = $_.Extension
        if (-not $filetypes.ContainsKey($ext)) { 
            $filetypes[$ext] = 0 
        }

        $filetypes[$ext] = $filetypes[$ext] + 1

        $counter = $counter + 1
        if ( ($counter % 100) -eq 1) {
            $pct = [math]::round(($counter * 100.0) / $filecount, 0)
            $lap = (Get-Date)
            $delta = (($lap - $start).TotalSeconds)

            $x = ($filecount / $counter) * $delta

            $secs = $x - $delta

            Write-Progress -Status 'In progress' -Activity 'Going through the file structure' -PercentComplete $pct -SecondsRemaining $secs
        }

    }
$end = (Get-Date)
$ElapsedTime = (($end - $start).TotalSeconds)
Write-Progress -Status 'Complete' -Activity "Total files: $filecount, summarized in $ElapsedTime seconds." -PercentComplete 100 -SecondsRemaining 0

$filetypes.GetEnumerator() | sort-object -descending -property value