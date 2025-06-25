$numbers = @(3, 2, 5, 6, 10,-2,23,1)
$sortedNumbers = $numbers | Sort-Object | ? { $_ -gt 5 }
$sortedNumbers