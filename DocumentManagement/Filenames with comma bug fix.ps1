## cd "C:\tmp\scripting"
cd "C:\GIT\PowerShell-Docs\scripting"
$filenamesWithCommas = @()
$filesToFix = @{}
Get-ChildItem -Path *.md -Recurse | ? { $_.FullName -like "*,*"} | % { $filenamesWithCommas += $_.Name }
Get-ChildItem -Path *.md -Recurse |`
 % { 
        $currentpath = $_.fullname; 
        foreach($fwc in $filenamesWithCommas){
            if(select-string -Path $currentpath -Pattern $fwc -SimpleMatch){ 
                if(-not $filesToFix.ContainsKey($fwc)){ 
                    $filesToFix.Add($fwc, @()) 
                }; 
                $filesToFix[$fwc] += $currentpath; 
            }
        }
    }
$filesToFix

Get-ChildItem -Path *.md -Recurse | `
 % { $currentpath = $_.fullname; ( (Get-Content $currentpath) | % {  foreach($fwc in $filenamesWithCommas){ $_ -creplace $fwc,$($fwc.Replace(",","")) }} | Set-Content -Path $currentpath ) } 

$filesToFix.Clear()
Get-ChildItem -Path *.md -Recurse |`
 % { 
        $currentpath = $_.fullname; 
        foreach($fwc in $filenamesWithCommas){
            if(select-string -Path $currentpath -Pattern $fwc -SimpleMatch){ 
                if(-not $filesToFix.ContainsKey($fwc)){ 
                    $filesToFix.Add($fwc, @()) 
                }; 
                $filesToFix[$fwc] += $currentpath; 
            }
        }
    }
if($filesToFix.Count -gt 0)
    { $filesToFix }
else
    { write-host "No files to fix"}