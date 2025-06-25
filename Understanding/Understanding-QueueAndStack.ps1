$queue = New-Object -TypeName System.Collections.Queue 
$queue.Enqueue("Uno")
$queue.Enqueue("Dos")
$queue.Enqueue("Tres")

while($queue.Count -gt 0) {
        $foo = $queue.Dequeue()
        Write-Host "» $foo" 
}

$stack = New-Object -TypeName System.Collections.Stack 
$stack.Push("Uno")
$stack.Push("Dos")
$stack.Push("Tres")

while($stack.Count -gt 0) {
        $foo = $stack.Pop()
        Write-Host "» $foo" 
}

