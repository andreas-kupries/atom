## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    sqlite3              test-database [file normalize _atom_[pid]_]
    [store-class] create test-store    test-database atoms
    return
}

proc release-store {} {
    catch { test-store    destroy }
    catch { test-database close   }
    file delete [file normalize _atom_[pid]_]
    return
}

# # ## ### ##### ######## ############# #####################
return
