Remove-Variable -Name docsfolder -Force -ErrorAction SilentlyContinue
Remove-Variable -Name fileSystemReferencePattern -Force -ErrorAction SilentlyContinue

[string]$docsfolder = "C:\GIT\PowerShell-Docs\reference"

[string]$fileSystemReferencePattern = "(?<drive>(\\\\[A-Za-z][-_A-Za-z0-9]*|[A-Za-z]:))(\\[^\\/:)+"