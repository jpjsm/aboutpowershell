## ,"C:\GIT\PowerShell-Docs\reference\5.1"
$referenceFolder = @("C:\GIT\PowerShell-Docs\reference\5.0")
$onlineVersionPattern = "online\s+version\s*:\s*(?<fwdlink>https?://go.microsoft.com/fwlink/\?LinkId=(?<linkid>[0-9]+))"
$fwdlinksInfo = @()
$nofwdlinksInfo = @()
Get-ChildItem -Path $referenceFolder -Filter "*.md" -Recurse |
    Where-Object { -not $_.PSIsContainer -and ($_.FullName -notlike "*ignore*") -and ($_.Name -ne "TOC.md") -and ($_.Name -notlike "about*")} |
    ForEach-Object {
        $fullpath = $_.FullName
        $fwdlink = [string]::Empty
        $linkid = [string]::Empty
        $newreference = [string]::Empty

        $cmdletName = [System.IO.Path]::GetFileNameWithoutExtension($fullpath)
        $moduleName = [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName($fullpath)) 
        $content = [System.IO.File]::ReadAllText($fullpath)
        $regexoptions = [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase 
        $match = [System.Text.RegularExpressions.Regex]::Match($content, $onlineVersionPattern, $regexoptions)
        if($match.Success){
            $fwdlink = $match.Groups["fwdlink"]
            $linkid = $match.Groups["linkid"]
            $newreference = "https://msdn.microsoft.com/powershell/reference/5.1/$modulename/$cmdletName"
            $fwdlinksInfo +=  "$linkid`t$moduleName`t$cmdletName`t$fwdlink`t$newreference"
        }
        else {
            $nofwdlinksInfo +=  $fullpath
        }

    }


[System.IO.File]::WriteAllLines("c:\tmp\New50FwdlinkReferences.txt",$fwdlinksInfo,[System.Text.UTF8Encoding]::UTF8)
[System.IO.File]::WriteAllLines("c:\tmp\No-FwdlinkReferences.txt",$nofwdlinksInfo,[System.Text.UTF8Encoding]::UTF8)