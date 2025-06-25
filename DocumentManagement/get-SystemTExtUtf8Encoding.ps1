$encodingPattern = "System\.Text\..*(UTF8|Encod)"

$scriptsFolder = "C:\git\juanpablo.jofre@bitbucket.org\powershell"

Get-ChildItem -Path $scriptsFolder -Recurse |
    Select-String -Pattern $encodingPattern -AllMatches |
    ForEach-Object {
        $filename = $_.Path
        $linenumber = $_.LineNumber
        $line = $_.Line

        Write-Output "$filename $linenumber $line"
    }