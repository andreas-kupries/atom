# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based atom storage i.e. string internement.
## Note, this does not use in-memory caching.
## If that is wanted see the cacher class.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require atom
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create atom::sqlite {
    superclass atom

    # # ## ### ##### ######## #############
    ## State

    variable mytable \
	sql_toid sql_tostr sql_exists \
	sql_map sql_extend sql_clear \
	sql_names sql_size sql_existsid
    # Name of the database table used for interning,
    # plus the commands to access it.

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
	    if {[DB onecolumn $sql_exists]} {
		return [DB onecolumn $sql_toid]
	    }
	    DB eval $sql_extend
	    return [DB last_insert_rowid]
	}
    }

    # str: integer -> string
    # map numeric identifier back to its string
    method str {id} {
	if {![DB onecolumn $sql_existsid]} {
	    my Error "Expected string id, got \"$id\"" BAD ID $id
	}
	return [DB onecolumn $sql_tostr]
    }

    # names () -> list(string)
    # query set of interned strings.
    method names {} {
	return [DB eval $sql_names]
    }

    # exists: string -> boolean
    # query if string is known/interned
    method exists {string} {
	DB onecolumn $sql_exists
    }

    # exists-id: id -> boolean
    # query if id is known/interned
    method exists-id {id} {
	DB onecolumn $sql_existsid
    }

    # size () -> integer
    method size {} {
	return [DB eval $sql_size]
    }

    # map: string, integer -> ()
    # intern the string, force the associated identifier.
    # throws error on conflict with existing string/identifier.
    method map {string id} {
	DB transaction {
	    if {[DB onecolumn $sql_exists]} {
		set knownid [DB onecolumn $sql_toid]
		if {$knownid != $id} {
		    # mapped, id mismatch
		    my MAPerror string $string $knownid $id
		} else {
		    # already mapped, ignore
		    return $id
		}
	    } elseif {[DB onecolumn $sql_existsid]} {
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
	    DB eval $sql_map
	}
	return $id
    }

    # clear () -> ()
    # Remove all known mappings.
    method clear {} {
	DB eval $sql_clear
	return
    }

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	if {![llength [DB onecolumn {
	    SELECT name
	    FROM  sqlite_master 
	    WHERE type = 'table'
	    AND   name = :table
	}]]} {
	    # Table missing. Create.
	    DB eval [string map $map {
		CREATE TABLE "<<table>>"
		(  id     INTEGER PRIMARY KEY AUTOINCREMENT,
		   string TEXT    NOT NULL UNIQUE
		);
		-- id and string have implied indices on them
		-- as primary key and unique columns.
	    }]
	} else {
	    # TODO: Find a way to check that the schema is as expected.
	}

	# Generate the custom sql commands.

	set sql_toid [string map $map {
	    SELECT id
	    FROM   "<<table>>"
	    WHERE  string = :string
	}]

	set sql_tostr [string map $map {
	    SELECT string
	    FROM   "<<table>>"
	    WHERE  id = :id
	}]

	set sql_exists [string map $map {
	    SELECT count(*)
	    FROM   "<<table>>"
	    WHERE  string = :string
	}]

	set sql_existsid [string map $map {
	    SELECT count(*)
	    FROM   "<<table>>"
	    WHERE  id = :id
	}]

	set sql_map [string map $map {
	    INSERT
	    INTO   "<<table>>"
	    VALUES (:id, :string)
	}]

	set sql_extend [string map $map {
	    INSERT
	    INTO   "<<table>>"
	    VALUES (NULL, :string)
	}]

	set sql_clear [string map $map {
	    DELETE
	    FROM   "<<table>>"
	}]

	set sql_names [string map $map {
	    SELECT string
	    FROM   "<<table>>"
	}]

	set sql_size [string map $map {
	    SELECT count(*)
	    FROM   "<<table>>"
	}]

	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide atom::sqlite 0
return
