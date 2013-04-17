# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## sqlite based atom storage i.e. string internement.
## Note, this does not use in-memory caching.
## If that is wanted see the cacher class.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require OO
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
	sql_names sql_size
    # Name of the database table used for interning,
    # plus the commands to access it.

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {database table} {
	forward DB $database
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
	    DB sql_extend
	    return [DB last_insert_rowid]
	}
    }

    # str: integer -> string
    # map numeric identifier back to its string
    method str {id} {
	return [DB onecolumn $sql_tostr]
    }

    # names () -> list(string)
    # query set of interned strings.
    method names {} {
	return [DB eval $sql_names]
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
	    try {
		DB sql_map
	    } on error {e o} {
		return {*}$o $e
	    }
	}
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

	set sql_map [string map $map {
	    INSERT
	    INTO   "<<table>>"
	    VALUES (:id, :string)
	}

	set sql_extend [string map $map {
	    INSERT
	    INTO   "<<table>>"
	    VALUES (NULL, :string)
	}

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
