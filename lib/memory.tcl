# -*- tcl -*-
## (c) 2013-2016 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory atom storage i.e. string internement.

# @@ Meta Begin
# Package atom::memory 1
# Meta author      {Andreas Kupries}
# Meta category    String internment, database
# Meta description String interning in memory
# Meta location    http:/core.tcl.tk/akupries/atom
# Meta platform    tcl
# Meta require     {Tcl 8.5-}
# Meta require     TclOO
# Meta require     atom
# Meta require     debug
# Meta require     debug::caller
# Meta subject     {string internment} interning
# Meta summary     String interning in memory
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require atom
package require debug
package require debug::caller

# # ## ### ##### ######## ############# #####################

debug define atom/memory
debug level  atom/memory
debug prefix atom/memory {[debug caller] | }

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create atom::memory {
    superclass atom

    # # ## ### ##### ######## #############
    ## State

    variable mystring myid
    # mystring: dict (id -> string)
    # myid:     dict (string -> id)

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} {
	debug.atom/memory {}
	my clear
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # id: string -> integer
    # intern the string, return its unique numeric identifier
    method id {string} {
	debug.atom/memory {}
	if {![dict exists $myid $string]} {
	    set id [dict size $myid]
	    # Avoid conflicts with existing mappings. Such can occur
	    # for deserialized mappings whiuch have holes.
	    while {[dict exists $mystring $id]} {incr id}
	    # Inlined 'map' without checks.
	    dict set myid     $string $id
	    dict set mystring $id $string
	    return $id
	}
	return [dict get $myid $string]
    }

    # str: integer -> string
    # map numeric identifier back to its string
    method str {id} {
	debug.atom/memory {}
	if {![dict exists $mystring $id]} {
	    my Error "Expected string id, got \"$id\"" BAD ID $id
	}
	return [dict get $mystring $id]
    }

    # names () -> list(string)
    # query set of interned strings.
    method names {} {
	debug.atom/memory {}
	dict keys $myid
    }

    # exists: string -> boolean
    # query if string is known/interned
    method exists {string} {
	debug.atom/memory {}
	dict exists $myid $string
    }

    # exists-id: id -> boolean
    # query if id is known/interned
    method exists-id {id} {
	debug.atom/memory {}
	dict exists $mystring $id
    }

    # size () -> integer
    method size {} {
	debug.atom/memory {}
	dict size $myid
    }

    # map: string, integer -> ()
    # intern the string, force the associated identifier.
    # throws error on conflict with existing string/identifier.
    method map {string id} {
	debug.atom/memory {}
	# Check for conflicts with existing id or string.
	if {[dict exists $myid $string] &&
	    ([set knownid [dict get $myid $string]] != $id)} {
	    my MAPerror string $string $knownid $id
	} elseif {[dict exists $mystring $id] &&
		   ([set knownstr [dict get $mystring $id]] ne $string)} {
	    my MAPerror id $id $knownstr $string
	}

	dict set myid     $string $id
	dict set mystring $id $string
	return $id
    }

    # clear () -> ()
    # Remove all known mappings.
    method clear {} {
	debug.atom/memory {}
	set mystring {}
	set myid     {}
	return
    }

    # # ## ### ##### ######## #############
    ## API. Standard methods. Reimplementation possible
    ##      for efficiency. Plus alternate names.

    # Override base class. Efficient serialization.
    method serialize {} {
	debug.atom/memory {}
	return $myid
    }

    # Override base class. Efficient replacing deserialization.
    method load {serial} {
	debug.atom/memory {}
	set myid $serial
	set mystring {}
	dict for {string id} $serial {
	    dict set mystring $id $string
	}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide atom::memory 1
return
