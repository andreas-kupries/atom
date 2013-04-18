
proc make {n} {
    new-store
    push $n
    return
}

proc push {n} {
    mydb transaction {
	for {set i 0} {$i < $n} {incr i} {
	    myatom id $i
	}
    }
    return
}
