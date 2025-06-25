Remove-Variable -Name match* -Force
Remove-Variable -Name field -Force
Remove-Variable -Name cnt -Force
Remove-Variable -Name data -Force

$vCardFile = "D:\Public\Downloads\Juampa iPhone Contacts - 2016-10-24.vcf"

[string]$linepattern = "^((?<item>item[0-9]+\.)?(?<field>[^:;]+)(;(?<kvp>[A-za-z0-9]+=[^:;]*))*):(?<data>.*)$"

[INT]$cardid = 0
[string[]]$data = [System.IO.File]::ReadAllLines($vCardFile) | 
    Where-Object { -not [string]::IsNullOrWhiteSpace( $_) } 

[int]$top = $data.Length
$top = 1000

[int]$line = 0
[string[]]$lines = @()
[string]$row = [string]::Empty

$fields = @{} 

for([int]$i=0; $i -lt $top; $i++){
    $row += $data[$i]
    if(-not [string]::IsNullOrWhiteSpace($data[($i+1)]) -and ($data[($i+1)].StartsWith("\n") -or $data[($i+1)].StartsWith(" "))){
        continue
    }

    $lines += $row.Replace("\n", "`n")
    $row = [string]::Empty
    Write-Progress "Data: $i  Line $line"
    $line++
}

[int]$top = $lines.Length
[int]$cnt = 1
for([int]$i = 0; $i -lt $top; $i++){
    $matches = [System.Text.RegularExpressions.Regex]::Matches($lines[$i], $linepattern)
    $matches.GetEnumerator() |
        ForEach-Object {
            [string]$field = $_.Groups["field"].Value
            [string]$data = $_.Groups["data"].Value

            $fields[$field] += 1

            if($field -eq "n"){
                Write-Host   "$cnt : $data"
                $cnt++
            }
        }
}

$fields