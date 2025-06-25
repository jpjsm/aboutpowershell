<#

#>


$originalVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"
. ".\Get-Relativepath.ps1"

$testDirectory = "C:\tmp\Pictures"
$testValues = @{}
$testValues.Add("C:\tmp\Pictures\hello.txt","hello.txt")
$testValues.Add("C:\tmp\Pictures\Greetings\hello.txt","Greetings\hello.txt")
$testValues.Add("C:\tmp\Pictures\Greetings\To All Beings\hello.txt","Greetings\To All Beings\hello.txt")
$testValues.Add("C:\tmp\hello.txt","..\hello.txt")
$testValues.Add("C:\users\hello.txt","..\..\users\hello.txt")
$testValues.Add("C:\users\public\hello.txt","..\..\users\public\hello.txt")
$testValues.Add("C:\hello.txt","..\..\hello.txt")

$results = @{}

$testValues.GetEnumerator() |`
    ForEach-Object { 
        [string]$key = $_.Key
        [string]$value = $_.Value
        [string]$receivedValue = Get-RelativePath -Directory $testDirectory -FilePath $key; 
        [int]$compareResult = [System.String]::Compare($value, $receivedValue, [System.StringComparison]::InvariantCultureIgnoreCase)
        [boolean]$testResult = $compareResult -eq 0 
        Write-Verbose "$testResult ($compareResult): >$receivedValue< = >$value<"

        $results.Add($_.Key, $testResult)
    }

Write-Output ">>> Failed tests"
$results.GetEnumerator() | ForEach-Object { $testResult = $_.Value; if(-not $testResult) { Write-output $_.Key }}
Write-Output ">>> End of Failed tests"

$testDirectory = "C:\"
$testValues = @{}
$testValues.Add("C:\hello.txt","hello.txt")
$testValues.Add("C:\tmp\Pictures\hello.txt","tmp\Pictures\hello.txt")
$testValues.Add("C:\tmp\Pictures\Greetings\hello.txt","tmp\Pictures\Greetings\hello.txt")

$results = @{}

$testValues.GetEnumerator() |`
    ForEach-Object { 
        [string]$key = $_.Key
        [string]$value = $_.Value
        [string]$receivedValue = Get-RelativePath -Directory $testDirectory -FilePath $key; 
        [int]$compareResult = [System.String]::Compare($value, $receivedValue, [System.StringComparison]::InvariantCultureIgnoreCase)
        [boolean]$testResult = $compareResult -eq 0 
        Write-Verbose "$testResult ($compareResult): >$receivedValue< = >$value<"

        $results.Add($_.Key, $testResult)
    }

Write-Output ">>> Failed tests"
$results.GetEnumerator() | ForEach-Object { $testResult = $_.Value; if(-not $testResult) { Write-output $_.Key }}
Write-Output ">>> End of Failed tests"

$VerbosePreference = $originalVerbosePreference
