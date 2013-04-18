## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    sqlite3 mydb :memory:
    set b [atom::sqlite create mybackend ::mydb atoms]
    return [atom::cache create myatom $b]
}

proc release-store {} {
    catch { myatom    destroy }
    catch { mybackend destroy }
    catch { mydb      close }
    return
}

# # ## ### ##### ######## ############# #####################
return
