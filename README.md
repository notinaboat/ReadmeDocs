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


README"""## Interface"

README"""
    f1(a, b)
Documentation for `f1`.
"""
f1(a, b) = ...

README"""
    f2(x)
Documentation for `f2`.
"""
f1(a, b) = ...
end
```

e.g. Generate `README.md`:

```julia
julia> using Foo
julia> write("README.md", Foo.readme())
julia> println(read("README.md", String))
# Foo.jl

This is the Foo.jl Package.


## Interface

    f1(a, b)

Documentation for `f1`.


    f2(x)

Documentation for `f2`.


## Notes"

 * A...
 * B...
 * C...
```

