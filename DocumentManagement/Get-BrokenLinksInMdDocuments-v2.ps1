﻿<#

    .SYNOPSIS
        Test all MD references and report broken ones in a [TAB] separated list.

    .DESCRIPTION
        The command checks all inline links to see if those links
        have a valid reference. All MD documents in given folder and
        subfolders are verfied.

        References are checked for: 
        -   local files 
        -   URIs. 

    .PARAMETER  DocumentsFolder
        The path to the folder (with subfulders) that contains all MD documents to validate.

    .PARAMETER  BrokenLinkReportPrefix
        The file prefix for all reports.

    .PARAMETER  $fixBrokenLinks
        A switch to enable fixing broken links.

    .OUTPUTS
        

    .EXAMPLE
        <script-repository>\Find-BrokenLinksInMDDocuments.ps1 "<repo-location>\scripting"
        
        
#>
[CmdletBinding()]
Param(
  [string]$DocumentsFolder ,
  [string]$BrokenLinkReportPrefix,
  [switch]$fixBrokenLinks
)

<#
    .NOTES
    -   Variable usage
        $brokenlinks, $linkreferences : Array of hashtable --> each element of the array is a hashtable

        $brokenlinks is a subset of $linkedreferences

        !! each hashtable has the following items in it:
            link: the matched reference in the document
            path: the document's path
            linenumber: the line number, in the document, were the reference is found

    -   Keeping user preferences --> $initialWarningPreference, $initialErrorActionPreference

    .TODO
    -   Add exclude patterns
    -   Add switch to fix broken links
    -   Add save to file
    -   Enable save statistics
#>

. "C:\GIT\bitbucket.juanpablojofre\powershell\PowerShell-Docs\DocumentManagement\Get-Relativepath.ps1"
$initialWarningPreference = $WarningPreference
$initialErrorActionPreference = $ErrorActionPreference

$mdLinkPattern = "\[([^\[\]]+?)\]\(([^\(\)]+(\([^\(\)]+\))?[^\(\)]+?)\)"

$brokenlinks = @() ## an array of hashtable items
$linksDictionary = @{}

$linkreferences = get-childitem -Path $documentsfolder -Filter "*.md" -recurse |`
    Where-Object { $_.Directory.FullName -notlike "*.ignore*" } |`
    ForEach-Object { 
        if(-not $linksDictionary.ContainsKey( $_.Name)) {$linksDictionary.Add($_.Name, @())}
        $linksDictionary[$_.Name] += $_.FullName
        $_
    } |`
    Select-String $mdLinkPattern -AllMatches |`
    ForEach-Object { 
        $currentPath = $_.Path;
        $currentLineNumber = $_.linenumber 
        $_.Matches | ForEach-Object { $_.Captures | ForEach-Object {  @{link=$_.Groups[2].value;path=$currentPath;linenumber=$currentLineNumber;nestedParentheses=$_.Groups[3].value } } } }

$uniqueLinksDictionary = @{}
$linksDictionary.GetEnumerator() | ? { $_.Value.Length -eq 1} | % { $uniqueLinksDictionary.Add($_.Key, $_.Value[0]) }


$referencesProcessed = 0;
foreach( $lr in $linkreferences) {
        ## Report progress 
        $referencesProcessed++
        
        if(($referencesProcessed % 10) -eq 0) {
            $msg = "Processing reference {0,5} of {1,6} total. broken links found {2,5} --> [{3} | {4}]" -f $referencesProcessed,$linkreferences.count,$brokenlinks.count,($lr["path"]),($lr["link"]); 
            write-progress $msg
        }

        ## Split on internal anchor
        $linksplit = $lr["link"] -split "#"; 


        if((-not $linksplit[0]) -and ($linksplit.count -eq 2) ) {
            ## Checking in-doc reference or bookmarks 
            $anchor = $linksplit[1]
            $anchorPatternMatch = "<a\s+name=`"$anchor`"\s*(>.*<)*/a>"
            $anchorfound = Get-Content -Path $lr["path"] | Select-String $anchorPatternMatch -AllMatches
            if( ! $anchorfound){
                $brokenlinks += $lr;
            }

            continue;
        }

        ## Test if Web URI
        [string]$testUri = $lr["link"].ToString()
        if($testUri.ToLowerInvariant().StartsWith("http")){
            $r = $null;
            try
            {
                $WarningPreference = 'SilentlyContinue'                $ErrorActionPreference = 'SilentlyContinue'                ($r = Invoke-WebRequest -URI $testUri -MaximumRedirection 5 -WarningAction SilentlyContinue  -ErrorAction SilentlyContinue -errorvariable ignoreerror) 2>$null 1>$null
            }
            catch
            {
                ## Do nothing => SilentlyContinue
            }
            finally
            {
                $WarningPreference = $initialWarningPreference                $ErrorActionPreference = $initialErrorActionPreference            }

            if(($r.StatusCode -ge 200) -and ($r.StatusCode -le 299)) { 
                continue 
            }
            elseif(($r.StatusCode -ge 300) -and ($r.StatusCode -le 399)) { 
                ## Redirections in excess of -MaximumRedirection are logged out and treated as a broken link
                $document = $lr["path"]
                $redirmsg = $("Redirection found, code# " + $($r.StatusCode) + " for $testUri in $document")
                Write-Warning $redirmsg
            }

            $brokenlinks += $lr;
            continue;
        }



        ## Test to see if it is pointing to a local file
        $documentFolder = [System.IO.Path]::GetDirectoryName( $($lr["path"]))
        $currentPath = $linksplit[0].Replace("/","\")
        $currentPath = Join-Path -Path $documentFolder -ChildPath $currentPath

        try {

            $WarningPreference = 'SilentlyContinue'            $ErrorActionPreference = 'SilentlyContinue'
            if( Test-Path $currentPath) {
                ## Check if it carries an internal reference or bookmark
                if($linksplit.count -eq 2){
                    $anchor = $linksplit[1]
                    $anchorPatternMatch = "<a\s+name=`"$anchor`"\s*(>.*<)*/a>"
                    $anchorfound = Get-Content -Path $currentPath | Select-String $anchorPatternMatch 
                    if( ! $anchorfound){
                        $brokenlinks += $lr;
                    }
                } 

                continue;
            }
        }
        catch {
            ## Do nothing => SilentlyContinue
            Write-Host $_
            Write-Host "Current path: $currentPath"
        }
        finally
        {
            $WarningPreference = $initialWarningPreference            $ErrorActionPreference = $initialErrorActionPreference        }



        $brokenlinks += $lr;
}

$msg = "Processing reference {0,5} of {1,6} total. broken links found {2,5} " -f $referencesProcessed,$linkreferences.count,$brokenlinks.count; 
write-progress $msg

$documentBrokenLinks = @{}

$brokenLinksReport = $brokenlinks | ForEach-Object { 
    $documentDirectory = [System.IO.Path]::GetDirectoryName($_["path"])
    [string]$currentLink = $_["link"]
    $isUniqueName = $false
    $uniqueName = ""
    $relativePath = ""

    [string]$nameInBrokenLink = ""
    if(-not ($currentLink.StartsWith("#") -or $currentLink.ToLowerInvariant().StartsWith("http"))){
        $cleanLink = (($currentLink).Split("#"))[0]
        $nameInBrokenLink = ([System.IO.Path]::GetFileName($cleanLink)); 
        $isUniqueName = $uniqueLinksDictionary.ContainsKey( $nameInBrokenLink )
        if($isUniqueName){
            $uniqueName = $uniqueLinksDictionary[$nameInBrokenLink]
            $relativePath = Get-RelativePath -Directory $documentDirectory -FilePath $uniqueName -UseWebPathSeparator

            if(-not $documentBrokenLinks.ContainsKey($_["path"])){
                $documentBrokenLinks.Add($_["path"], @{})
            }



            $documentBrokenLinks[$_["path"]][$cleanLink] = $relativePath;
        }
    }

    write-output $("{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}" -f $_["path"],$_["linenumber"],$_["link"], $nameInBrokenLink, $isUniqueName, $uniqueName, $relativePath, $fixBrokenLinks )

     
} 

if($fixBrokenLinks -and $documentBrokenLinks.Count -gt 0){
    $documentBrokenLinks.GetEnumerator() |`        ForEach-Object {             $DocumentWithBrokenLinks = $_.Key;             $brokenLinksInDocument = $_.Value            $currentContent = [System.IO.File]::ReadAllText($DocumentWithBrokenLinks)            $brokenLinksInDocument.GetEnumerator() |`                ForEach-Object {                    $brokenLink = $_.Key                    $fixedLink = $_.Value                    $currentContent = $currentContent.Replace($brokenLink,$fixedLink)                }            [System.IO.File]::WriteAllText($DocumentWithBrokenLinks, $currentContent)        }
}

if(-not [string]::IsNullOrWhiteSpace($BrokenLinkReportPrefix))
{
    $BrokenLinkReportPrefix = $BrokenLinkReportPrefix.Trim()
}
else
{
    $BrokenLinkReportPrefix = [string]::Empty
}

$linkreferences | ForEach-Object { Write-Output $("{0}`t{1}`t{2}`t{3}" -f $_["path"],$_["linenumber"],$_["link"],$_["nestedParentheses"])} > $("$BrokenLinkReportPrefix-LinkedReferences {0}.tsv" -f [DateTime]::Now.ToString("yyyy-MM-dd HHmm") )
$brokenLinksReport > $("$BrokenLinkReportPrefix-Broken Links Report {0}.tsv" -f [DateTime]::Now.ToString("yyyy-MM-dd HHmm") )
$documentBrokenLinks.GetEnumerator() |`    ForEach-Object {         $DocumentWithBrokenLinks = $_.Key;         $_.Value.GetEnumerator() |`            ForEach-Object {                $brokenLink = $_.Key                $fixedLink = $_.Value                Write-Output "$DocumentWithBrokenLinks`t$brokenLink`t$fixedLink"            }    } > $("$BrokenLinkReportPrefix-Document Broken Links Fix {0}.tsv" -f [DateTime]::Now.ToString("yyyy-MM-dd HHmm") )