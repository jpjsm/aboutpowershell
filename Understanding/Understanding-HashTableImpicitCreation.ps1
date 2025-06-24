$repeatedNumbers = @(1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3)

$numberFrequency = @{}

foreach($number in $repeatedNumbers)
{
    $numberFrequency[$number] += 1
}

$numberFrequency