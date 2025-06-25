workflow DoSomeWork
{
    Param($collection)

    if($collection)
    {
        foreach -parallel ($item in $collection)
        {
            $item
        }
    }
}

$numbers = 1..100
DoSomeWork $numbers