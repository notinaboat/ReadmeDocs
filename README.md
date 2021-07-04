# ReadmeDocs.jl

Automated creation of `README.md` from API documentation for simple Packages.

e.g. Use `README"..."` strings to document `Foo/src/Foo.jl`:

```julia
"""
# Foo.jl

This is the Foo.jl Package.
"""
module Foo
export f1, f2
using ReadmeDocs


README"## Interface"

README"""
    f1(a, b) -> Foo

Compute `Foo` for `a` and `b`.
"""
f1(a, b) = ...

README"""
    f2(x) -> Bar

Compute `Bar` for `x`.
"""
f1(a, b) = ...

README"""
## Notes"

 * A...
 * B...
 * C...
"""

end # module Foo.jl
```

e.g. Generate `README.md`:

```julia
julia> using Foo
julia> write("README.md", Foo.readme())
julia> println(read("README.md", String))
# Foo.jl

This is the Foo.jl Package.


## Interface

    f1(a, b) -> Foo

Compute `Foo` for `a` and `b`.


    f2(x) -> Bar

Compute `Bar` for `x`.


## Notes"

 * A...
 * B...
 * C...
```

See also example [`Makefile`](Makefile).

