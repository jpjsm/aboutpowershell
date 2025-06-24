Remove-Variable -Name fields -Force -ErrorAction SilentlyContinue
Remove-Variable -Name field -Force -ErrorAction SilentlyContinue
Remove-Variable -Name htmltext -Force -ErrorAction SilentlyContinue
Remove-Variable -Name testcase -Force -ErrorAction SilentlyContinue
Remove-Variable -Name linepattern -Force -ErrorAction SilentlyContinue
Remove-Variable -Name data -Force -ErrorAction SilentlyContinue
Remove-Variable -Name mtchs -Force -ErrorAction SilentlyContinue

[string]$htmltext = '<!DOCTYPE html><html lang="en" xmlns="http://www.w3.org/1999/xhtml"><head><meta charset="utf-8" /><title>Test</title></head><body>Hello World!</body></html>'

[string]$testcase = "iteM98.NAME;encoding=UTF8;type=txt/html;length=156:" + $htmltext

[string]$linepattern = "^((?<item>item[0-9]+\.)?(?<field>[^:;]+)(;(?<kvp>[A-za-z0-9]+=[^:;]*))*):(?<data>.*)$"

$fields = @{} 


$mtchs = [System.Text.RegularExpressions.Regex]::Matches($testcase, $linepattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$mtchs.GetEnumerator() |
    ForEach-Object {
        [string]$field = $_.Groups["field"].Value
        $_.Groups["kvp"].Captures.GetEnumerator() |
            ForEach-Object{
                $kvp =$_.Value 
                Write-Host "kvp: $kvp"
            }

        $fields[$field] += 1
    }

for([int]$i = 0; $i -lt ($mtchs.Groups.Count); $i++) {
    Write-Host ("[{0,2:N0}] »{1}«" -f $i, ($mtchs.Groups[$i]))
}

