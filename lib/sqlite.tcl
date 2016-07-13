# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based atom storage i.e. string internement.
## Note, this does not use in-memory caching.
## If that is wanted see the cacher class.

# @@ Meta Begin
# Package atom::sqlite 0
# Meta author      {Andreas Kupries}
# Meta category    String internment, database
# Meta description String interning via Sqlite database
# Meta location    http:/core.tcl.tk/akupries/atom
# Meta platform    tcl
# Meta require     {Tcl 8.5-}
# Meta require     TclOO
# Meta require     atom
# Meta require     dbutil
# Meta require     sqlite3
# Meta subject     {string internment} interning
# Meta summary     String interning via Sqlite database
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require atom
package require dbutil
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create atom::sqlite {
    superclass atom

    # # ## ### ##### ######## #############
    ## State

    variable mytable \
	sql_toid sql_tostr sql_map sql_extend sql_clear \
	sql_names sql_size sql_serial
    # Name of the database table used for interning,
    # plus the sql commands to access it.

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {database table} {
	# Make the database available as a local command, under a
	# fixed name. No need for an instance variable and resolution.
	interp alias {} [self namespace]::DB {} $database

	my InitializeSchema $table
	return
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # id: string -> integer
    # intern the string, return its unique numeric identifier
    method id {string} {
	DB transaction {
	    if {[DB exists $sql_toid]} {
		return [DB onecolumn $sql_toid]
	    }
	    variable size
	    if {[info exists size]} { incr size }
	    DB eval $sql_extend
	    return [DB last_insert_rowid]
	}
    }

    # str: integer -> string
    # map numeric identifier back to its string
    method str {id} {
	DB transaction {
	    if {![DB exists $sql_tostr]} {
		my Error "Expected string id, got \"$id\"" BAD ID $id
	    }
	    return [DB onecolumn $sql_tostr]
	}
    }

    # names () -> list(string)
    # query set of interned strings.
    method names {} {
	DB transaction {
	    return [DB eval $sql_names]
	}
    }

    # exists: string -> boolean
    # query if string is known/interned
    method exists {string} {
	DB transaction {
	    DB exists $sql_toid
	}
    }

    # exists-id: id -> boolean
    # query if id is known/interned
    method exists-id {id} {
	DB transaction {
	    DB exists $sql_tostr
	}
    }

    # size () -> integer
    method size {} {
	variable size
	if {[info exists size]} { return $size }
	DB transaction {
	    set size [DB eval $sql_size]
	}
	# implied return
    }

    # map: string, integer -> ()
    # intern the string, force the associated identifier.
    # throws error on conflict with existing string/identifier.
    method map {string id} {
	DB transaction {
	    if {[DB exists $sql_toid]} {
		set knownid [DB onecolumn $sql_toid]
		if {$knownid != $id} {
		    # mapped, id mismatch
		    my MAPerror string $string $knownid $id
		} else {
		    # already mapped, ignore
		    return $id
		}
	    } elseif {[DB exists $sql_tostr]} {
		set knownstr [DB onecolumn $sql_tostr]
		if {$knownstr ne $string} {
		    # mapped, string mismatch
		    my MAPerror id $id $knownstr $string
		} else {
		    # already mapped, ignore
		    return $id
		}
	    }
	    # unknown mapping, no conflicts, enter.
	    variable size
	    if {[info exists size]} { incr size }
	    DB eval $sql_map
	}
	return $id
    }

    # clear () -> ()
    # Remove all known mappings.
    method clear {} {
	variable size ; unset -nocomplain size
	DB transaction {
	    DB eval $sql_clear
	}
	return
    }

    # # ## ### ##### ######## #############
    ## API. Standard methods. Reimplemented to place all low-level
    ## operations into transactions, reducing amount of disk access.

    # serialize: () -> dict (string -> identifier)
    method serialize {} {
	return [DB eval $sql_serial]
    }

    # deserialize: dict (string -> identifier) -> ()
    method deserialize {serial} {
	DB transaction {
	    dict for {string id} $serial {
		my map $string $id
	    }
	}
	return
    }

    # load: dict (string -> identifier) -> ()
    method load {serial} {
	variable size ; unset -nocomplain size
	DB transaction {
	    DB eval $sql_clear
	    dict for {string id} $serial {
		my map $string $id
	    }
	}
	return
    }

    # merge: dict (string -> identifier) -> ()
    method merge {serial} {
	DB transaction {
	    dict for {string _} $serial {
		my id $string
	    }
	}
	return
    }

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	if {![dbutil initialize-schema $fqndb reason $table {{
	    id     INTEGER PRIMARY KEY AUTOINCREMENT,
	    string TEXT    NOT NULL UNIQUE
	} {
	    {id     INTEGER 0 {} 1}
	    {string TEXT    1 {} 0}
	}}]} {
	    my Error $reason BAD SCHEMA
	}

	# Generate the custom sql commands.
	my Def sql_extend   { INSERT            INTO "<<table>>" VALUES (NULL, :string) }
	my Def sql_map      { INSERT            INTO "<<table>>" VALUES (:id, :string)  }
	my Def sql_clear    { DELETE            FROM "<<table>>" }
	my Def sql_toid     { SELECT id         FROM "<<table>>" WHERE string = :string }
	my Def sql_tostr    { SELECT string     FROM "<<table>>" WHERE id     = :id     }
	my Def sql_names    { SELECT string     FROM "<<table>>" }
	my Def sql_serial   { SELECT string, id FROM "<<table>>" }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" }

	return
    }

    method Def {var sql} {
	upvar 1 map map
	set $var [string map $map $sql]
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide atom::sqlite 0
return
