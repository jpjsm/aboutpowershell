[string]$sourceFolder = "C:\GIT\PowerShell-Docs\reference\"
[string]$comparedFolder = "C:\PSReferenceConversion\reference\"

. C:\GIT\juanpablo.jofre@bitbucket.org\powershell\PowerShell-Docs\DocumentManagement\Get-MergeFolderDifferences.ps1 -sourceFolder $sourceFolder -comparedFolder $comparedFolder 

$unmatchedCmpFiles | 
    ForEach-Object {
        [string]$from = [System.IO.Path]::Combine($comparedFolder, $_) 
        [string]$to = [System.IO.Path]::Combine($sourceFolder, $_)
        [string]$parentTo = [System.IO.Path]::GetDirectoryName($to)

        [string]$content = [System.IO.File]::ReadAllText($from)

        if(-not [System.IO.Directory]::Exists($parentTo)){
            [System.IO.Directory]::CreateDirectory($parentTo)
        }

        [System.IO.File]::WriteAllText($to, $content, [System.Text.UTF8Encoding]::UTF8)
    }