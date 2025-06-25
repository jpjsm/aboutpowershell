function Update-MDCodeBlockLanguage() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
            [ValidateNotNullOrEmpty()]
            [ValidateScript( { (Test-Path -LiteralPath $_ -PathType Leaf) -and 
                ([System.IO.Path]::GetExtension($_) -eq ".md") })] 
            [string]$DocumentPath
        , [ValidateSet("UTF8BOM", "UTF8NOBOM", 
            "ASCII", "UTF7",
            "UTF16BigEndian", "UTF16LittleEndian", "Unicode",
            "UTF32BigEndian", "UTF32LittleEndian")]
        [string] $encode = "UTF8NOBOM"        
    )
    
    BEGIN {
        [string]$line
    }

    PROCESS {
        Write-Progress $DocumentPath
        [string[]]$NewContent = [System.IO.File]::ReadAllLines($DocumentPath, (Get-EncodingFromLabel -encode $encode)) | 
            ForEach-Object {
                $line = $_
                if($line.StartsWith('```')) {
                    $line = $line.ToLowerInvariant()
                }

                $line
            }
        
        [System.IO.File]::WriteAllLines($DocumentPath, $NewContent, (Get-EncodingFromLabel -encode $encode))
    }
}