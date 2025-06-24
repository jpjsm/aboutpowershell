$outfolder = "C:\PowerShell 6 Reference\5.1\CimCmdlets"

[hashtable]$pages = @{
  "Export-BinaryMiLog" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/export-binarymilog"
  "Get-CimAssociatedInstance" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/get-cimassociatedinstance"
  "Get-CimClass" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/get-cimclass"
  "Get-CimInstance" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/get-ciminstance"
  "Get-CimSession" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/get-cimsession"
  "Import-BinaryMiLog" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/import-binarymilog"
  "Invoke-CimMethod" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/invoke-cimmethod"
  "New-CimInstance" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/new-ciminstance"
  "New-CimSession" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/new-cimsession"
  "New-CimSessionOption" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/new-cimsessionoption"
  "Register-CimIndicationEvent" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/register-cimindicationevent"
  "Remove-CimInstance" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/remove-ciminstance"
  "Remove-CimSession" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/remove-cimsession"
  "Set-CimInstance" = "https://technet.microsoft.com/en-us/itpro/powershell/windows/cim/set-ciminstance"
}

. 'C:\GIT\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\Get-WebContentToMarkdown.ps1'

Get-WebContentToMarkdown -outputfolder $outfolder -inputPages $pages