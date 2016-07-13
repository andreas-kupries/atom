# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Cache storage. Internally uses in-memory store.
## Backend store is configurable at construction time).

# @@ Meta Begin
# Package atom::cache 0
# Meta author      {Andreas Kupries}
# Meta category    String internment, database
# Meta description Cache in front of arbitrary string interning backend
# Meta location    http:/core.tcl.tk/akupries/atom
# Meta platform    tcl
# Meta require     {Tcl 8.5-}
# Meta require     TclOO
# Meta require     atom
# Meta require     atom::memory
# Meta subject     {string internment} interning
# Meta summary     Cache in front of arbitrary string interning backend
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require atom
package require atom::memory

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create atom::cache {
    superclass atom

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {backend} {
	# Make the backend available as a local command, under a fixed
	# name. No need for an instance variable and resolution.
	interp alias {} [self namespace]::BACKEND {} $backend

	# The cache itself is also handled as a local command.
	atom::memory create CACHE
	CACHE clear
	return
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # id: string -> integer
    # intern the string, return its unique numeric identifier
    method id {string} {
	if {![CACHE exists $string]} {
	    # Using "map" here forces the mapping in the cache to 
	    # mirror the mapping by the backend.
	    return [CACHE map $string [BACKEND id $string]]
	} else {
	    return [CACHE id $string]
	}
    }

    # str: integer -> string
    # map numeric identifier back to its string.
    # check cache first, then backend, lift mapping.
    method str {id} {
	if {![CACHE exists-id $id]} {
	    # Using "map" here forces the mapping in the cache to
	    # mirror the mapping by the backend.
	    set string [BACKEND str $id]
	    CACHE map $string $id
	    return $string
	} else {
	    return [CACHE str $id]
	}
    }

    # names () -> list(string)
    # query set of interned strings.
    # backend is authoritative source.
    # cache may not know everything, yet.
    #method names {} { BACKEND names }
    forward names BACKEND names

    # exists: string -> boolean
    # query if string is known/interned
    # check cache first, then the authoritative source.
    method exists {string} {
	set has [CACHE exists $string]
	if {$has} { return $has }
	return [BACKEND exists $string]
    }

    # exists-id: id -> boolean
    # query if id is known/interned
    # check cache first, then the authoritative source.
    method exists-id {id} {
	set has [CACHE exists-id $id]
	if {$has} { return $has }
	return [BACKEND exists-id $id]
    }

    # size () -> integer
    # backend is authoritative source.
    # cache may not know everything, yet.
    #method size {} { BACKEND size }
    forward size BACKEND size

    # map: string, integer -> ()
    # intern the string, force the associated identifier.
    # throws error on conflict with existing string/identifier.
    method map {string id} {
	# Works because the cached mapping mirrors the backend (see
	# method [id] above).
	BACKEND map $string $id
	CACHE   map $string $id
	return $id
    }

    # clear () -> ()
    # Remove all known mappings.
    method clear {} {
	BACKEND clear
	CACHE   clear
	return
    }

    # # ## ### ##### ######## #############
    ## Cache bypass.

    forward serialize   BACKEND serialize
    forward deserialize BACKEND deserialize
    forward load        BACKEND load
    forward merge       BACKEND merge

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide atom::cache 0
return
