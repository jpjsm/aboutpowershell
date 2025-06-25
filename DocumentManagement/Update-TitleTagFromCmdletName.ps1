function Update-TitleTagFromCmdletName(){
  [CmdletBinding()]
  param(
    [parameter(Mandatory=$true)] [ValidateScript({ Test-Path -LiteralPath $_ })] [string] $referencefolder,
    [parameter(Mandatory=$false)] [string] $outputfolder
  )
    
  BEGIN{
    ## Define UTF8 No-BOM encoder/decoder
    $Utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

    [string[]]$NoTitleTag = @()
    [string[]]$TitlesWithSpaces = @()
    [string]$titleTagPattern = "^title\s*:\s*(?<title>.*)$"
    [string]$titleHeaderPattern = "^#\s+(?<title>.*)$"
    [string]$properCmdletNamePattern = "[A-Za-z][A-Za-z_]+-[A-Za-z][A-Za-z0-9_]+"
    [System.Text.RegularExpressions.RegexOptions]$multilineCI = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase + [System.Text.RegularExpressions.RegexOptions]::Multiline
  }
  
  PROCESS{
    Get-ChildItem -Path $referencefolder -Filter "*.md" -Recurse |
    Where-Object { ($_.FullName -notlike "*about_*") -and ($_.Name -ne "toc.md") -and ($_.Name -like "*-*")} |
    ForEach-Object { 
      [string]$TopicPath = $_.FullName
      [string]$CmdletFileName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
      [string]$Topic = [System.IO.File]::ReadAllText($TopicPath)

      [int]$TopicLen = $Topic.Length
      Write-Progress "$TopicPath : $TopicLen"
      
      [string]$Title = [string]::Empty
      [string]$TitleLine = [string]::Empty
      $TitleMatch = [System.Text.RegularExpressions.Regex]::Match($Topic,$titleTagPattern, $multilineCI)
      if ($TitleMatch.Success) {
        $Title = $TitleMatch.Groups["title"].Value.Trim()
        $TitleLine = $TitleMatch.Groups[0].Value
      }
      else {
        $NoTitleTag += $TopicPath
      }


      if ($Title -notmatch $properCmdletNamePattern) {     
        [string]$TopicTitle = [string]::Empty
        $TopicTitleMatch = [System.Text.RegularExpressions.Regex]::Match($Topic,$titleHeaderPattern, $multilineCI)
        if ($TopicTitleMatch.Success) {
          $TopicTitle = $TopicTitleMatch.Groups["title"].Value.Trim()
        }

        if ([string]::IsNullOrWhiteSpace($TopicTitle))
        {
          $TopicTitle = $CmdletFileName.Trim()
        }
        
        $TitlesWithSpaces += "$TopicPath : $Title --> $TopicTitle"
    
        [string]$NewTitleTag = "title: $TopicTitle"
        $Topic = $Topic.Replace($TitleLine, $NewTitleTag)
        [System.IO.File]::WriteAllText($TopicPath, $Topic, $Utf8NoBom)   
        Write-Warning "Updated: $TopicPath"    
      }
        
    }
  }
  
  END{
    if($outputfolder -and (Test-Path -LiteralPath $outputfolder -pathType container)){
      [string]$timestamp = [datetime]::Now.ToString("yyyy-MM-dd_HHmmss")
      [System.IO.File]::WriteAllLines((Join-Path -Path $outputfolder -ChildPath "$timestamp TitlesWithSpaces.txt"), $TitlesWithSpaces, $Utf8NoBom)
      [System.IO.File]::WriteAllLines((Join-Path -Path $outputfolder -ChildPath "$timestamp NoTitleTag.txt"), $NoTitleTag, $Utf8NoBom)
    }
  }
}



