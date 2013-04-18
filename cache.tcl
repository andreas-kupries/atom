# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## Cache storage. Internally uses in-memory store.
## Backend store is configurable at construction time).

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
	    # Using "map" here forces the mapping in cache to 
	    # mirror the mapping by the backend.
	    return [CACHE map $string [BACKEND id $string]]
	} else {
	    return [CACHE id $string]
	}
    }

    # str: integer -> string
    # map numeric identifier back to its string
    #method str {id} { CACHE str $id }
    forward str CACHE str


    # names () -> list(string)
    # query set of interned strings.
    #method names {} { CACHE names }
    forward names CACHE names

    # exists: string -> boolean
    # query if string is known/interned
    #method exists {string} { CACHE exists $string }
    forward exists CACHE exists

    # size () -> integer
    #method size {} { CACHE size }
    forward size CACHE size

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

    forward serialize   CACHE serialize
    forward deserialize CACHE deserialize
    forward load        CACHE load
    forward merge       CACHE merge

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide atom::cache 0
return
