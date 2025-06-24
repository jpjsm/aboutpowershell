##  $modulesfolder = "C:\tmp\v6"
$modulesfolder = "C:\GIT\PowerShell-Docs\reference\6"

# Constants and general variables
[string]$headerpattern = "^#+\s+"
[System.Text.RegularExpressions.Regex]$headerregex = [System.Text.RegularExpressions.Regex]::new($topicheaderpattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

[string]$topicheaderpattern = "^###\s+\[(?<topic>[-._A-Za-z0-9]+)\]\(\1\.md\)"
[System.Text.RegularExpressions.Regex]$topicheaderregex = [System.Text.RegularExpressions.Regex]::new($topicheaderpattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

[bool]$endoftopics = $false

# start execution
Get-ChildItem -Path $modulesfolder |
  Where-Object { $_.PSIsContainer -eq $true } |
  ForEach-Object {
    $modulename = $_.Name
    $modulesfolder = $_.FullName
    $modulelandingpagepath = [System.IO.Path]::Combine($modulesfolder, "$modulename.md") 
    $moduleoldlandingpagepath = [System.IO.Path]::Combine($modulesfolder, "$modulename.old.md") 
        
    $topics = @{}
    Get-ChildItem -Path $modulesfolder -Filter "*.md" -Recurse |
    Where-Object { (($_.FullName) -ne $modulelandingpagepath) -and (($_.FullName) -ne $moduleoldlandingpagepath)  } |
    ForEach-Object {
      $topicname = ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)).ToLowerInvariant().Trim()
      $topics.Add($topicname, @{})
    }
    
    if ([System.IO.File]::Exists($modulelandingpagepath))
    {
      # Update existing landing page
      [System.Text.StringBuilder]$landingpagecontent = [System.Text.StringBuilder]::new()
      
      ##  Load landing page
      [string[]]$landingpagelines = [System.IO.File]::ReadAllLines($modulelandingpagepath)
      
      ##  Parse landing page
      [int]$linenumber = 0
      
      ###  Skip through metadata and initial tags      
      while (($linenumber -lt $landingpagelines.Length) -and (-not $topicheaderregex.IsMatch($landingpagelines[$linenumber])))
      {
        $landingpagecontent.AppendLine($landingpagelines[$linenumber]) > $null
        $linenumber += 1
      }
      
      ### Filter matching content
      while (($linenumber -lt $landingpagelines.Length) -and ($topicheaderregex.IsMatch($landingpagelines[$linenumber])))
      {
        [string]$topicname = $topicheaderregex.Match($landingpagelines[$linenumber]).Groups["topic"].Value.ToString().Trim()
        [string]$topicnamelowercase = $topicname.ToLowerInvariant()
        $linenumber += 1
        
        [System.Text.StringBuilder]$topiccontent = [System.Text.StringBuilder]::new()        
        while (($linenumber -lt $landingpagelines.Length) -and (-not $headerregex.IsMatch($landingpagelines[$linenumber])))
        {
          $topiccontent.AppendLine($landingpagelines[$linenumber]) > $null
          $linenumber += 1
        }
        
        if ($topics.ContainsKey($topicnamelowercase))
        {
          $topics[$topicnamelowercase].Add("Name", $topicname)
          $topics[$topicnamelowercase].Add("Content", $topiccontent.ToString())
        }
              
        if (-not $topicheaderregex.IsMatch($landingpagelines[$linenumber]) -and $headerregex.IsMatch($landingpagelines[$linenumber]))
        {
          $endoftopics = $true
          break
        }        
      }      
      
      ##  Complete document
      ###  Iterate over topics in alphabetical order
      $topics.Keys.GetEnumerator() |
      Sort-Object |
      ForEach-Object {
        [string]$topicnamelowercase = $_
          
        if ($topics[$topicnamelowercase].ContainsKey("Name"))
        {
          # Content found in source document
          [string]$topicname = $topics[$topicnamelowercase]["Name"]
          [string]$content = $topics[$topicnamelowercase]["Content"]
            
          if ([string]::IsNullOrWhiteSpace($content))
          {
            $content = "{{Manually Enter $topicname Description Here}}"
          }
          
            
          $landingpagecontent.AppendLine("### [$topicname]($topicnamelowercase.md)") > $null
          $landingpagecontent.Append($content) > $null
        } else {
          $landingpagecontent.AppendLine("### [$topicnamelowercase]($topicnamelowercase.md)") > $null
          $landingpagecontent.AppendLine("{{Manually Enter $topicnamelowercase Description Here}}") > $null
          $landingpagecontent.AppendLine([string]::Empty) > $null
        }          
      }
      
      ###  Add any extra content
      if ($endoftopics)
      {
        while ($linenumber -lt $landingpagelines.Length)
        {
          $landingpagecontent.AppendLine($landingpagelines[$linenumber]) > $null
          $linenumber += 1
        }        
      }
      
      ###  Save file
      [System.IO.File]::WriteAllText($modulelandingpagepath, $landingpagecontent.ToString())
      
    } else {
      # Create landing page
      ##  Find module's guid
      Import-Module -Name $modulename
      [string]$moduleguid = (Get-Module -Name $modulename).Guid 
      
      ##  Create header
      [string]$landingpageheader = @"
---
Module Name: $modulename
Module Guid: $moduleguid
Download Help Link: http://Please-enter-FwLink-manually
Help Version: 6.0
Locale: en-US
---

# $modulename Module
## Description
{{Manually Enter Description Here}}

## $modulename Topics

"@
      ##  Create landingpage content
      [System.Text.StringBuilder]$landingpagecontent = [System.Text.StringBuilder]::new($landingpageheader)
      
      $topics.Keys.GetEnumerator() |
      ForEach-Object {
        [string]$topicname = $_
        $landingpagecontent.AppendLine("### [$topicname]($topicname.md)") > $null
        $landingpagecontent.AppendLine("{{Manually Enter $topicname Description Here}}") > $null
        $landingpagecontent.AppendLine([string]::Empty) > $null
      }
    
      $landingpagecontent.AppendLine([string]::Empty) > $null

      [System.IO.File]::WriteAllText($modulelandingpagepath, $landingpagecontent.ToString())    
    }
  }
