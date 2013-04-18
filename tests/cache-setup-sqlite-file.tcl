## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    global store_path
    set    store_path [file normalize _atom_[pid]_]
    sqlite3 mydb $store_path
    set b [atom::sqlite create mybackend ::mydb atoms]
    return [atom::cache create myatom $b]
}

proc release-store {} {
    global store_path
    catch { myatom    destroy }
    catch { mybackend destroy }
    catch { mydb      close }
    file delete $store_path
    unset store_path
    return
}

# # ## ### ##### ######## ############# #####################
return
