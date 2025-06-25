$firstArray = @(1,2,3,4,5)
$secondArray = @('ab', 'cd', 'ef', 'gh', 'ij')
$combinedArray = @()
Write-Host "Combined array length: " $combinedArray.Length

$combinedArray += $firstArray
Write-Host "After adding First array, Combined array length: " $combinedArray.Length

$combinedArray += $secondArray
Write-Host "After adding First array, Combined array length: " $combinedArray.Length

$combinedArray | Out-File -FilePath c:\tmp\combinedArray.txt
