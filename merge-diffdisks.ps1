$diskslocation = 'C:\Hyper-V Exports\jpjofre-ubx-2204\Virtual Hard Disks'

$roots=@()
$connections=@{}
get-ChildItem -Path $diskslocation -Filter *vhdx | 
    get-vhd |
    ForEach-Object {
        $parent = $_.ParentPath
        $child = $_.Path 
        if ($parent) {
            $connections.Add($parent, $child)
        } else {
            $roots += $child
        }
    }

foreach($root in $roots){
    Write-Host "Root: $root"
    $chain = @($root)
    $key=$root
    while($connections.ContainsKey($key)){
        $chain += $connections[$key]
        $key = $connections[$key]
    }

    Write-Host "Chain: $chain"
    $chainlength = $chain.Length
    Write-Host "Chaining: $chainlength"
    Write-Host "Merging..."
    For(($i=$($chainlength - 2)); $i -ge 0; $i--){
        $parent = $chain[$i]
        $child = $chain[$($i + 1)]
        Write-Host "$parent <-- $child"
        merge-vhd -path $child -destinationpath $parent -v
    }

    Write-Host "Optimizing final disk"
    mount-vhd -path $chain[0] -readonly
    optimize-vhd -path $chain[0] -mode full
    dismount-vhd $chain[0]
}   
