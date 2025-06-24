[string[]] $CommonModules50 = [System.IO.File]::ReadAllLines("C:\tmp\CommonModules50.csv")
[string[]] $CommonModules51 = [System.IO.File]::ReadAllLines("C:\tmp\CommonModules51.csv")
$Cmdlets = @{}

$CommonModules50 + $CommonModules51 |
    ForEach-Object {
        $items = $_.Split(',')
        $cmdletName = $items[0]
        $psversion = $items[1]
        $moduleName = $items[2]
        $cmdletType = $items[3]
        $moduleVersion = $items[4]

        if(-not $Cmdlets.ContainsKey($cmdletName)){
            $Cmdlets.Add($cmdletName, @{})
        }

        if(-not $Cmdlets[$cmdletName].ContainsKey($psversion)){
            $Cmdlets[$cmdletName].Add($psversion, @{})

            $Cmdlets[$cmdletName][$psversion].Add("ModuleName", $moduleName)
            $Cmdlets[$cmdletName][$psversion].Add("CmdletType", $cmdletType)
            $Cmdlets[$cmdletName][$psversion].Add("ModuleVersion", $moduleVersion)
        }     
    }

$Cmdlets.GetEnumerator() |
    ForEach-Object {
        $cmdletName = $_.Key
        $VersionData = $_.Value
        if($VersionData.Count -eq 1){
            [string] $psversion = $VersionData.Keys[0]
            Write-Output ("{0,-30} {1,-3} {2,-10} {3}" -f $cmdletName, $psversion, $VersionData[$psversion]["CmdletType"], $VersionData[$psversion]["ModuleName"])
        }
    }