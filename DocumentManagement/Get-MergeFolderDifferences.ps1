[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$sourceFolder ,
    [parameter(Mandatory=$true)][string]$comparedFolder
)
    
if(-not $sourceFolder.EndsWith("\")){
    $sourceFolder += "\"
}

if(-not $comparedFolder.EndsWith("\")){
    $comparedFolder += "\"
}

[int]$srcFlrLen = $sourceFolder.Length
[int]$cmpFlrLen = $comparedFolder.Length

$sourceFilesMatches = @{}
$comparedFilesMatches = @{}

## Get relative paths for source and compared
Get-ChildItem -Path $sourceFolder -Recurse |
    Where-Object { -not $_.PSIsContainer } |
    ForEach-Object{
        $fileName = ($_.FullName).Substring($srcFlrLen).ToLowerInvariant()
        $sourceFilesMatches.Add($fileName, $false)
        Write-Progress "Source file added: " $_.FullName
    }

Get-ChildItem -Path $comparedFolder -Recurse |
    Where-Object { -not $_.PSIsContainer } |
    ForEach-Object{
        $fileName = ($_.FullName).Substring($cmpFlrLen).ToLowerInvariant()
        $comparedFilesMatches.Add($fileName, $false)
        Write-Progress "Compare file added: " $_.FullName
    }

## Find matching paths between sorce and compared
[string[]]$srcKeys = $sourceFilesMatches.GetEnumerator() |
    ForEach-Object{
        $_.Key.ToString()
    }

$srcKeys |
    ForEach-Object {
        [string]$path = $_
        if($comparedFilesMatches.ContainsKey($path)){
            $sourceFilesMatches[$path] = $true
            $comparedFilesMatches[$path] = $true
            Write-Progress "Match found: " $path
        }
    }


## Find matches that have different content        
## Find un-matched files
$unmatchedSrcFiles = @()
$unmatchedCmpFiles = @()

$matchContent = @{}

$srcMatchStats = @{ $true = 0; $false = 0}

$sourceFilesMatches.GetEnumerator() |
    ForEach-Object{
        [string]$path = $_.Key
        [bool]$IsMatched = $_.Value

        $srcMatchStats[$IsMatched] += 1

        if($IsMatched){
            $sourceFileInfo = Get-Item -Path (Join-Path $sourceFolder $path) 
            $comparedFileInfo = Get-Item -Path (Join-Path $comparedFolder $path) 
            if(($sourceFileInfo.Length -eq $comparedFileInfo.Length) -and 
                ((Get-FileHash -Path ($sourceFileInfo.FullName)).Hash -eq (Get-FileHash -Path ($comparedFileInfo.FullName)).Hash)){
                $matchContent[$path] = $true
            }
            else{
                $matchContent[$path] = $false
            }            
        }
        else{
            $unmatchedSrcFiles += $path
            Write-Progress "»»    Un-matched source: " $path
        }
    }


$cmpMatchStats = @{ $true = 0; $false = 0}

$comparedFilesMatches.GetEnumerator() |
    ForEach-Object{
        [string]$path = $_.Key
        [bool]$IsMatched = $_.Value

        $cmpMatchStats[$IsMatched] += 1

        if(-not $IsMatched){
            $unmatchedCmpFiles += $path
            Write-Progress "»»    Content different: "$path
        }
    }

$matchContentStats = @{}
$matchContentStats = @{ $true = 0; $false = 0}
$differentContentPaths = @()


$matchContent.GetEnumerator() |
    ForEach-Object {
        $matchContentStats[($_.Value)] += 1
        if(-not ($_.Value)){
            $differentContentPaths += ($_.Key)
        }
    }



##
## Spill verbose documentation
##
if($VerbosePreference -eq "Continue"){
    Write-Verbose "     "
    Write-Verbose "Unmatched Source Files"
    Write-Verbose "----------------------"
    $unmatchedSrcFiles | Write-Verbose

    Write-Verbose "     "
    Write-Verbose "Unmatched Compared Files"
    Write-Verbose "------------------------"
    $unmatchedCmpFiles | Write-Verbose


    Write-Verbose "     "
    Write-Verbose "Different Content Files"
    Write-Verbose "-----------------------"
    $differentContentPaths | Write-Verbose


    Write-Verbose "     "
    Write-Verbose "Source Match Statistics"
    Write-Verbose "-----------------------"
    $srcMatchStats.GetEnumerator() |
        ForEach-Object{
            Write-Verbose ("{0,-7} {1:N0}" -f $_.Key, $_.Value)
        }

    Write-Verbose "     "
    Write-Verbose "Compared Match Statistics"
    Write-Verbose "-------------------------"
    $cmpMatchStats.GetEnumerator() |
        ForEach-Object{
            Write-Verbose ("{0,-7} {1:N0}" -f $_.Key, $_.Value)
        }

    Write-Verbose "     "
    Write-Verbose "Matched Paths Content Similarity Statistics"
    Write-Verbose "-------------------------------------------"
    $matchContentStats.GetEnumerator() |
        ForEach-Object{
            Write-Verbose ("{0,-7} {1:N0}" -f $_.Key, $_.Value)
        }
}
