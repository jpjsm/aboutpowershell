$a = 'one', 'two', 'three'

# Checks if 'ONE' is on the list (case insensitive)
$a -contains 'ONE'

# This doesn't work as expected!
# Even though one would imagine that list of 'one', 'two' is a subset of 'one', 'two', 'three'
# contains treats 'one', 'two' as a single object an compares that object with each element on the LHS list.
$a -contains 'one', 'two'

($a -contains 'one') -and ($a -contains 'two')