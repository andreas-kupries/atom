# -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## Base class for atom storage i.e. string internement.
##
## This class declares the API all actual classes have to
## implement. It also provides standard APIs for the
## de(serialization) of atom stores.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require OO

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create atom {
    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.

    # id: string -> integer
    # intern the string, return its unique numeric identifier
    method id {string} { my APIerror id }

    # str: integer -> string
    # map numeric identifier back to its string
    method str {id} { my APIerror str }

    # names () -> list(string)
    # query set of interned strings.
    method names {} { my APIerror names }

    # exists: string -> boolean
    # query if string is known/interned
    method exists {string} { my APIerror exists }

    # size () -> integer
    method size {} { my APIerror size }

    # map: string, integer -> ()
    # intern the string, force the associated identifier.
    # throws error on conflict with existing string/identifier.
    # returns id.
    method map {string id} { my APIerror map }

    # clear () -> ()
    # Remove all known mappings.
    method clear {} { my APIerror clear }

    # # ## ### ##### ######## #############
    ## API. Standard methods. Reimplementation possible
    ##      for efficiency. Plus alternate names.

    forward <-- my deserialize
    forward --> my serialize
    forward :=  my load
    forward +=  my merge

    # serialize: () -> dict (string -> identifier)
    method serialize {} {
	set serial {}
	foreach string [my names] {
	    dict set serial $string [my id $string]
	}
	return $serial
    }

    # Various forms of reading a serialized atom storage.

    # deserialize: dict (string -> identifier) -> ()
    method deserialize {serial} {
	dict for {string id} $serial {
	    my map $string $id
	}
	return
    }

    # load: dict (string -> identifier) -> ()
    method load {serial} {
	my clear
	my deserialize $serial
	return
    }

    # merge: dict (string -> identifier) -> ()
    method merge {serial} {
	dict for {string _} $serial {
	    my id $string
	}
	return
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list ATOM {*}$args] $txt
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }
}

# # ## ### ##### ######## ############# #####################
package provide atom 0
return
