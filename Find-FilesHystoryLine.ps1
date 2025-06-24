$sourceFolders = 'C:\repos\fcm-hipri-demo\change-risk-estimator\app', 'C:\repos\fcm-hipri-demo\common', 'C:\repos\fcm-hipri-demo\EventsRetrieval\app', 'C:\repos\fcm-hipri-demo\ExceptionRequest\app', 'C:\repos\fcm-hipri-demo\services-information\app'
$include_filters =  @('\.cs$')
$exclude_filters = @('\\bin\\', '\\obj\\', '\\\.git\\', '\\\.vs\\')
$FileHistoryDictionary = @{}
foreach ($sourceFolder in $sourceFolders) {
    Get-ChildItem -Path $sourceFolder -Recurse
    | Where-Object {
        $exclude_filter = "(" + [System.String]::Join("|", $exclude_filters) + ")"
        if ($_.FullName -notmatch $exclude_filter) {
            $_
        }
    }
    | Where-Object {
        $include_filter = "(" + [System.String]::Join("|", $include_filters) + ")"
        if ($_.FullName -match $include_filter) {
            $_
        }
    }
    | ForEach-Object { 
        $FullName = $_.FullName
        $Name = $_.Name

        if (-not $FileHistoryDictionary.ContainsKey($Name)) {
            $FileHistoryDictionary.Add($Name, @())
        }

        $FileHistoryDictionary[$Name]+= $FullName
    }
}

$FileHistoryDictionary.Keys |
    Sort-Object |
    Where-Object {$FileHistoryDictionary[$_].Count -gt 1 } |
    ForEach-Object {
        $Key = $_
        Write-Host $Key
        $FileHistoryDictionary[$Key] | Get-Item | Sort-Object -Property UpdateDate | ForEach-Object { $FileName = $_.FullName; Write-Host "`t$FileName" }
    }