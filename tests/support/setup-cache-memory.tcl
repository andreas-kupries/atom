## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    atom::memory create test-backend
    [store-class] create test-store test-backend
    return
}

proc release-store {} {
    catch { test-store   destroy }
    catch { test-backend destroy }
    return
}

# # ## ### ##### ######## ############# #####################
return
