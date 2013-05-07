## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## A number of shared test cases have different results, based on the
## internals of identifier generation.  The code here provides the
## setup for the internals of atom::sqlite, and compatible.

# # ## ### ##### ######## ############# #####################

# Standard id for the n'th interned string.
# n counting from 1.
proc nth {x} { return $x }

# deserialize-[12].6
proc deserX6char {} { return A }

# map-1.5, merge-[12].6
# sqlite autoincrement - simply starting from max(id).
# no filling in of holes in the existing map.
# myatom id s ; # nominal 6
# myatom id a ; # nominal 7
# myatom id g ; # nominal 8
proc map15 {} { return {A 3 a 7 g 8 L 1 S 5 s 6} }

# # ## ### ##### ######## ############# #####################
return
