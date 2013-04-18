## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## A number of shared test cases have different results, based on the
## internals of identifier generation.  The code here provides the
## setup for atom::memory generation.

# # ## ### ##### ######## ############# #####################

# Standard id for the n'th interned string.
# n counting from 1.
proc nth {x} { incr x -1 }

# deserialize-[12].6
proc deserX6char {} { return S }

# map-1.5, merge-[12].6
# memory uses dict size as generator, and then increments while conflicting.
# this can fill in holes, at least partially.
# myatom id s ; # nominal 3, avoid, go 4
# myatom id a ; # nominal 4, avoid, avoid 5, go 6
# myatom id g ; # nominal 5, avoid, avoid 6, go 7
proc map15 {} { return {A 3 a 6 g 7 L 1 S 5 s 4} }

# # ## ### ##### ######## ############# #####################
return
