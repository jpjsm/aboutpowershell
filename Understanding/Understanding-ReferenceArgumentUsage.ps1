function ArgumentsByReference
{
    param($repeatedNumbers, $fabricName, [ref]$serverToRackLookup, [ref]$networkDeviceToRackLookup, $dcCodeMap)

    Write-Host "Racks" $racks

    if($serverToRackLookup.Value -eq $null)
    {
        $serverToRackLookup.Value = @{}
    }

    if($networkDeviceToRackLookup.Value -eq $null)
    {
        $networkDeviceToRackLookup.Value = @{}
    }


    foreach($number in $repeatedNumbers)
    {
        $serverToRackLookup.Value[$number] += 1
        $networkDeviceToRackLookup.Value[$number] += $number
    }

}

$serverToRackLookup = @{}
$networkDeviceToRackLookup = @{}

$repeatedNumbers = @(1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3)

$logFile = "C:\tmp\AddContentData.txt"
ArgumentsByReference $repeatedNumbers $fabricName ([ref]$serverToRackLookup) ([ref]$networkDeviceToRackLookup) $dcCodeMap

$serverToRackLookup

$networkDeviceToRackLookup

$repeatedNumbers = @(4,5,6,4,5,6,4,5,6,4,5,6,4,5,6,4,5,6)

ArgumentsByReference $repeatedNumbers $fabricName ([ref]$serverToRackLookup) ([ref]$networkDeviceToRackLookup) $dcCodeMap

$serverToRackLookup > $logFile 

$networkDeviceToRackLookup >> $logFile
