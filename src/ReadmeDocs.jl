"""
# ReadmeDocs.jl

Automated creation of `README.md` from API documentation for simple Packages.

e.g. Use `README"..."` strings to document `Foo/src/Foo.jl`:

```julia
\"\"\"
# Foo.jl

This is the Foo.jl Package.
\"\"\"
module Foo
export f1, f2
using ReadmeDocs


README"## Interface"

README\"\"\"
    f1(a, b) -> Foo

Compute `Foo` for `a` and `b`.
\"\"\"
f1(a, b) = ...

README\"\"\"
    f2(x) -> Bar

Compute `Bar` for `x`.
\"\"\"
f1(a, b) = ...

README\"\"\"
## Notes"

 * A...
 * B...
 * C...
\"\"\"

end # module Foo.jl
```

... then generate `README.md`:

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

"""
module ReadmeDocs

export @README_str,
       @ARCH_str


const sections = ["README", "ARCH"]

mutable struct ModuleDocs
    mod::Module
    docs::Vector{Tuple}
    ModuleDocs(mod) = new(mod, [])
end


function search_meta(meta, path, line)
    for (k, v) in meta
        for doc in values(v.docs)
            if doc.data[:linenumber] == line &&
               doc.data[:path] == path
                return doc.data
           end
       end
    end
end


function generate(moddocs::ModuleDocs)

    meta = moddocs.mod.eval(Docs.META)

    if basename(pwd()) != string(moddocs.mod)
        throw(ArgumentError("""
            ReadmeDocs.generate should be run from the package home directory.
            Expected `pwd()` to be \"$(moddocs.mod)\" (was \"$(pwd())\").
            """))
    end

    output = Dict(x => [] for x in sections)
    index = Dict(x => [] for x in sections)

    push!(output["README"], string(Docs.doc(moddocs.mod)))

    @info "Finding docstrings..."
    for (type, doc, path, line) in moddocs.docs
        x = search_meta(meta, path, line)
        if x != nothing
            name = string(x[:binding])
            @show doc
            if !startswith(doc, "#")
                doc = "\n### `$name`\n\n$doc"
            end
            push!(index[type], (:ref, name))
        else
            push!(index[type], (:text, doc))
        end
        push!(output[type], doc)
    end
    for (name, content) in output
        @info "Generating $name.md"
        write("$name.md", join(content, "\n"))
    end

    mkpath("docs/src/")

    for (section, content) in index
        if section == "README"
            section = "index"
            output = """
                # $(moddocs.mod).jl

                ```@docs
                $(moddocs.mod)
                ```
                """
        else
            output = "# $section\n\n"
        end
        @info "Generating docs/src/$section.md"
        for (type, x) in content
            if type == :text
                output *= "$x\n"
            elseif type == :ref
                output *= """
                    ```@docs
                    $x
                    ```
                    """
            end
        end
        write("docs/src/$section.md", output)
    end
end


const readme_docs_init = quote
    global readme_docs
    global readme_docs_generate
    if !isdefined(@__MODULE__, :readme_docs)
        const readme_docs = ReadmeDocs.ModuleDocs(@__MODULE__)
        const readme_docs_generate = ()->ReadmeDocs.generate(readme_docs)
    end
end


macro README_str(s)
    s = Meta.parse("\"\"\"$s\"\"\"")
    esc(:(let s = $s
          $readme_docs_init
          push!(readme_docs.docs,
                ("README",
                s,
                $(string(__source__.file)),
                $(Int(__source__.line))))
          s
      end))
end

macro ARCH_str(s)
    s = Meta.parse("\"\"\"$s\"\"\"")
    esc(:(let s = $s
          $readme_docs_init
          push!(readme_docs.docs,
                ("ARCH",
                s,
                $(string(__source__.file)),
                $(Int(__source__.line))))
          s
      end))
end

readme() = Docs.doc(@__MODULE__)



end # module
