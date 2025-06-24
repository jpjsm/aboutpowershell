function Get-StringHash()
{
    [CmdletBinding()]
    Param(
      [parameter(Mandatory=$true)][string]$string2hash
    )

    $md5 = [System.Security.Cryptography.MD5]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string2hash)
    $hashbytes = $md5.ComputeHash($bytes)
    return [System.Guid]::new($hashbytes).ToString()
}

[string] $referenceFolder50 = "C:\GIT\PowerShell-Docs\reference\5.0"
[string] $referenceFolder51 = "C:\GIT\PowerShell-Docs\reference\5.1"


[string[]]$referenceFolders = @($referenceFolder50, $referenceFolder51)
[string]$onlineVersionPattern = "online\s+version\s*:\s*(?<fwdlink>https?://go.microsoft.com/fwlink/\?LinkId=(?<linkid>[0-9]+))"

$docs = @{}

$referenceFolders |
    ForEach-Object {
        [string]$referenceFolder = $_
        [string]$version = [System.IO.Path]::GetFileName($referenceFolder)

        Get-ChildItem -Path $referenceFolder -Filter "*.md" -Recurse |
            Where-Object { -not $_.PSIsContainer -and ($_.FullName -notlike "*ignore*") -and ($_.Name -ne "TOC.md") -and ($_.Name -notlike "about*")} |
            ForEach-Object {
                $fullpath = $_.FullName
                $relativepath = $fullpath.Substring(($referenceFolder.Length + 1))
                $fwdlink = [string]::Empty
                $linkid = [string]::Empty

                $cmdletName = [System.IO.Path]::GetFileNameWithoutExtension($fullpath)
                $moduleName = [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName($fullpath)) 
                $content = [System.IO.File]::ReadAllText($fullpath)
                $regexoptions = [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase 
                $match = [System.Text.RegularExpressions.Regex]::Match($content, $onlineVersionPattern, $regexoptions)
                if($match.Success){
                    $fwdlink = $match.Groups["fwdlink"]
                    $linkid = $match.Groups["linkid"]
                }

                if(-not $docs.ContainsKey($relativepath)) {
                    $docs.Add($relativepath, @{})
                }

                if(-not $docs[$relativepath].ContainsKey($version)) {
                    $docs[$relativepath].Add($version, @{"fwdlink" = $fwdlink; "linkid" = $linkid})
                }
            }
    }

[string[]]$matchedFwdLinks=@()
[string[]]$incompleteFwdLinks=@()
$textReplacements = @{}

$docs.GetEnumerator() |
    ForEach-Object {
        [string]$relativepath = $_.Key
        $versions = $_.Value

        [string]$linkid50 = [string]::Empty
        [string]$fwdlink50 = [string]::Empty
        [string]$linkid51 = [string]::Empty
        [string]$fwdlink51 = [string]::Empty

        if($versions.ContainsKey("5.0")) {
            $linkid50 = $versions["5.0"]["linkid"]
            $fwdlink50 = $versions["5.0"]["fwdlink"]
        }

        if($versions.ContainsKey("5.1")) {
            $linkid51 = $versions["5.1"]["linkid"]
            $fwdlink51 = $versions["5.1"]["fwdlink"]
        }

        New-Object -TypeName PSObject -Property @{
            'RelativePath' = $relativepath
            'LinkId50' = $linkid50
            'FwdLink50' = $fwdlink50
            'LinkId51' = $linkid51
            'FwdLink51' = $fwdlink51
        }
    } |
    Sort-Object -Property RelativePath |
    ForEach-Object {
        if((-not [string]::IsNullOrWhiteSpace($_.LinkId50)) -and 
           (-not [string]::IsNullOrWhiteSpace($_.LinkId51))) {
            $matchedFwdLinks += "{0}`t{1}`t{2}`t{3}`t{4}" -f (($_.RelativePath), ($_.LinkId50), ($_.FwdLink50), ($_.LinkId51), ($_.FwdLink51))
            $textReplacements[($_.FwdLink51)] = $_.FwdLink50
        }
        else {
            $incompleteFwdLinks += "{0}`t{1}`t{2}`t{3}`t{4}" -f (($_.RelativePath), ($_.LinkId50), ($_.FwdLink50), ($_.LinkId51), ($_.FwdLink51)) 
        }
    }

$matchedFwdLinks

[System.IO.File]::WriteAllLines("C:\tmp\MatchedFwdLinks.txt", $matchedFwdLinks, [System.Text.UnicodeEncoding]::Unicode)
[System.IO.File]::WriteAllLines("C:\tmp\IncompleteFwdLinks.txt", $incompleteFwdLinks, [System.Text.UnicodeEncoding]::Unicode)

[int]$updatedFiles = 0
Get-ChildItem -Path $referenceFolder51 -Filter "*.md" -Recurse |
    ForEach-Object {
        $fullpath = $_.FullName
        [string]$content = [System.IO.File]::ReadAllText($fullpath)
        $originalhash = Get-StringHash -string2hash $content
        $textReplacements.GetEnumerator() |
            ForEach-Object {
                $oldfwdlink = $_.Key
                $newfwdlink = $_.Value
                $content = $content.Replace($oldfwdlink,$newfwdlink)
            }

        $newhash = Get-StringHash -string2hash $content

        if($originalhash -ne $newhash) {
            Write-Host "Updated: $fullpath"
            $updatedFiles++
            [System.IO.File]::WriteAllText($fullpath, $content, [System.Text.UTF8Encoding]::UTF8)
        }
    }

Write-Host "Total files updated: $updatedFiles"
