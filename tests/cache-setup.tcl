## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    set b [atom::memory create mybackend]
    return [atom::cache create myatom $b]
}

proc release-store {} {
    catch { myatom    destroy }
    catch { mybackend destroy }
    return
}

# # ## ### ##### ######## ############# #####################
return
