function New-AboutLandingPage {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)] 
      [ValidateScript({Test-Path $_ })] 
      [String[]] $aboutfolders,
      [ValidateSet("UTF8BOM", "UTF8NOBOM", 
                 "ASCII", "UTF7",
                 "UTF16BigEndian","UTF16LittleEndian","Unicode",
                 "UTF32BigEndian","UTF32LittleEndian")]
    [string] $encode = "UTF8NOBOM"
)

  BEGIN {
    [string]$topicname = [string]::Empty
    [string]$topicfilename = [string]::Empty
    [string]$description = [string]::Empty
    [string]$aboutfolder = [string]::Empty
    [string]$aboutfoldername = [string]::Empty

    [System.Text.StringBuilder]$content = [System.Text.StringBuilder]::new()
    
    $AboutHeader = @"
---
Module Name: About
Module Guid: 00000000-0000-0000-0000-000000000000
Download Help Link: http://Please-enter-FwLink-manually
Help Version: 6.0
Locale: en-US
---

# About Module
## Description
{{Manually Enter Description Here}}

## About Topics


"@

  }

  PROCESS {
    [System.Text.Encoding]$encoding = Get-EncodingFromLabel -encode $encode

    $aboutfolders |
      ForEach-Object {
        $aboutfolder = $_
        $aboutfoldername = [System.IO.Path]::GetFileName($aboutfolder)

        $content = [System.Text.StringBuilder]::new($AboutHeader)

        $topics = Get-ChildItem -Path $aboutfolder -Filter "*.md" |

        [bool]$containsSeekedFiles = $false
        $topics.ForEach{
            if(($_.Name -eq "$aboutfoldername.md") -or ($_.Name -eq "readme.md")) {
              $containsSeekedFiles = $true; 
            }; 
          }

        if (-not $containsSeekedFiles) {
          $topics |
            Where-Object {($_.Name -ne "$aboutfoldername.md") -and ($_.Name -ne "readme.md") -and (($_.Name -ne "toc.md"))} |
            ForEach-Object {
              $topicname = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
              $topicfilename = $_.FullName
              $description = Get-ShortDescription -aboutPath $topicfilename -encode $encode

              if ([string]::IsNullOrWhiteSpace($description)) {
                $description = "{{Manually Enter $topicname Description Here}}"
              }
              
              $content.AppendLine("### [$topicname]($topicname.md)") > $null
              $content.AppendLine($description) > $null
              $content.AppendLine([string]::Empty) > $null
            }
            
          [string]$AboutFileName = [System.IO.Path]::Combine($aboutfolder, "$aboutfoldername.md")
          [System.IO.File]::WriteAllText($AboutFileName, $content.ToString(), $encoding)
          Write-Progress "$AboutFileName"
        }
      }
  }

}
