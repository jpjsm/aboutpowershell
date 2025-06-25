function Do-Something (){
    [CmdletBinding()]
    Param(
        [parameter (Mandatory = $true, ParameterSetName="File")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -LiteralPath $_ -PathType Leaf })] 
        [string]$DocumentFile 
        , [parameter (Mandatory = $true, ParameterSetName="Text")]
        [ValidateNotNullOrEmpty()]
        [string]$Text 
        , [parameter (Mandatory = $false, ParameterSetName="File")]
        [ValidateSet("UTF8BOM", "UTF8NOBOM", 
            "ASCII", "UTF7",
            "UTF16BigEndian", "UTF16LittleEndian", "Unicode",
            "UTF32BigEndian", "UTF32LittleEndian")]
        [string] $encode = "UTF8NOBOM"
    )

    BEGIN {
        [string]$repeatingWordPattern = "(\s|\r*\n)(?<dup>(?<word>\p{L}[\p{L}\p{N}_'-]*)(\s|\r*\n)+\k<word>)"
        [System.Text.RegularExpressions.RegexOptions]$regexOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase + [System.Text.RegularExpressions.RegexOptions]::Singleline
    }   

    END {
        if ($DocumentFile) {
            $Text = [System.IO.File]::ReadAllText($DocumentFile, (Get-EncodingFromLabel -encode $encode))
        }

        $matches = [System.Text.RegularExpressions.Regex]::Matches($Text, $repeatingWordPattern, $regexOptions)
        if($matches.Success){
            $matches.GetEnumerator() |
                ForEach-Object {
                    Write-Output ($_.Groups["dup"].value -replace "\r*\n","\n")
                }
        }
    } 
}
