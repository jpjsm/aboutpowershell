$infile = "C:\tmp\About-MD\about_Arithmetic_Operators.md"
$outfile = "C:\tmp\About-TXT\about_Arithmetic_Operators.txt"

[string[]]$arguments = @()
$arguments += @("-f", "markdown_github")  ## from format: markdown github
$arguments += @("-t", "plain")            ## to   format: text
$arguments += @("-s")                     ## standalone file; all output in one single file.
$arguments += @("--columns=40", "--wrap=auto")
$arguments += @("-o", $outfile)
$arguments += @($infile)
$arguments
& pandoc.exe $arguments