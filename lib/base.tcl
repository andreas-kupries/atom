# -*- tcl -*-
## (c) 2013-2016 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for atom storage i.e. string internment.
##
## This class declares the API all actual classes have to
## implement. It also provides standard APIs for the
## de(serialization) of atom stores.

# @@ Meta Begin
# Package atom 1
# Meta author      {Andreas Kupries}
# Meta category    String internment, database
# Meta description Base class for string interning
# Meta location    http:/core.tcl.tk/akupries/atom
# Meta platform    tcl
# Meta require     {Tcl 8.5-}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     {string internment} interning
# Meta summary     String interning
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

# # ## ### ##### ######## ############# #####################

debug define atom
debug level  atom
debug prefix atom {[debug caller] | }

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

    # exists-id: id -> boolean
    # query if id is known/interned
    method exists-id {id} { my APIerror exists-id }

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

    forward <-- my deserialize ; export <--
    forward --> my serialize   ; export -->
    forward :=  my load        ; export :=
    forward +=  my merge       ; export +=

    # serialize: () -> dict (string -> identifier)
    method serialize {} {
	debug.atom {}
	set serial {}
	foreach string [my names] {
	    dict set serial $string [my id $string]
	}

	debug.atom {==> ($serial)}
	return $serial
    }

    # Various forms of reading a serialized atom storage.

    # deserialize: dict (string -> identifier) -> ()
    method deserialize {serial} {
	debug.atom {}
	dict for {string id} $serial {
	    my map $string $id
	}

	debug.atom {/done}
	return
    }

    # load: dict (string -> identifier) -> ()
    method load {serial} {
	debug.atom {}
	my clear
	my deserialize $serial

	debug.atom {/done}
	return
    }

    # merge: dict (string -> identifier) -> ()
    method merge {serial} {
	debug.atom {}
	dict for {string _} $serial {
	    my id $string
	}

	debug.atom {/done}
	return
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	debug.atom {}
	return -code error -errorcode [list ATOM {*}$args] $text
    }

    method APIerror {api} {
	debug.atom {}
	my Error "Unimplemented API $api" API MISSING $api
    }

    method MAPerror {what val old new} {
	debug.atom {}
	set wx [string toupper $what]
	set wh [string totitle $what]
	my Error "$wh conflict for \"$val\", maps to \"$old\" != \"$new\"" \
	    MAP CONFLICT $wx $val $new $old
    }
}

# # ## ### ##### ######## ############# #####################
package provide atom 1
return
