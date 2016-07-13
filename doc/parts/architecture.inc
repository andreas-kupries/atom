
[para] All packages to one of two layers,
as shown below:

[para][image architecture]

[para] Note that:

[list_begin itemized]

[item] Packages marked with a dashed blue border are private.

[item] Packages marked with an unbroken blue border are fully public.

[item] The topmost layer contains only a single package,
[package [vset PROJECT]], the base class for all others.

[item] The other layer contains the various storage backends.
[list_end]

[para] The dependencies between the packages are very
straight-forward:

[para][image pkg_dependencies]
