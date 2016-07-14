# -*- tcl -*-
## (c) 2013-2016 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for atom storage i.e. string internement.
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
# Meta subject     {string internment} interning
# Meta summary     String interning
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO

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
	return -code error -errorcode [list ATOM {*}$args] $text
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }

    method MAPerror {what val old new} {
	set wx [string toupper $what]
	set wh [string totitle $what]
	my Error "$wh conflict for \"$val\", maps to \"$old\" != \"$new\"" \
	    MAP CONFLICT $wx $val $new $old
    }
}

# # ## ### ##### ######## ############# #####################
package provide atom 1
return
