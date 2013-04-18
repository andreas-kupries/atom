## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    sqlite3 mydb :memory:
    return [atom::sqlite create myatom ::mydb atoms]
}

proc release-store {} {
    catch { myatom destroy }
    catch { mydb     close }
    return
}

# # ## ### ##### ######## ############# #####################
return
