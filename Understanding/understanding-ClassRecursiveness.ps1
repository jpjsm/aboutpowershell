class bnode{
    $value 
    [bnode]$lnode
    [bnode]$rnode

    bnode($v) {
        $this.value = $v
    }

    bnode($v,$l,$r) {
        $this.value = $v
        $this.lnode = $l
        $this.rnode = $r        
    }
}

[bnode]$root = [bnode]::new(8)

$root.lnode = [bnode]::new(4)
$root.rnode = [bnode]::new(12)

$root