## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    return [atom::memory create myatom]
}

proc release-store {} {
    myatom destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
