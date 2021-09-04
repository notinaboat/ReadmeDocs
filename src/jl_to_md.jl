#!/usr/local/bin/julia

if length(ARGS) != 1
    @warn "usage: jl_to_md.jl jl_filename.jl"
    exit(1)
end



# Default methods.

enter(a...) = nothing
format(::Any, n, line) = line
leave(a...) = nothing


# Content Types.

struct Code end
struct Heading end
struct Doc end
struct FixMe end

format(::Heading, n, line) = "# $line"

format(::FixMe, n, line) = "FIXME[^FIXME$n]\n\n[^FIXME$n]: ⚠️ $line"

code_start(n) = """```julia"""
code_end = "```"

enter(::Code, v, n) = push!(v, code_start(n))

function leave(::Code, v)
    while last(v) == ""
        pop!(v)
    end
    push!(v, code_end, "")
end


"""
Read C source code from `c_filename`.
Convert C comments to Markdown.
Convert C code to Markdown code blocks.
Write output to `\$c_filename.md`.
"""
function c_to_md(c_filename)

    md_filename = "$c_filename.md"

    v = String[]
    state = Code

    for (n, line) in enumerate(eachline(c_filename))

        for ((pattern_state, pattern), next_state) in [
            (Doc,   r"^ \"\"\"                         $"x) => nothing,
            (Doc,   r"^          (.*?)                 $"x) => Doc(),
            (Any,   r"^ [#] [ ]* FIXME (.*?) [ ]*      $"x) => FixMe(),
            (Any,   r"^ [#] [ ]* (.+?) [ ]*            $"x) => Heading(),
            (Any,   r"^ [@]doc [ ] README\"\"\"        $"x) => Doc(),
            (Any,   r"^ \"\"\"                         $"x) => Doc(),
            (Code,  r"^          (.*?)                 $"x) => Code(),
            (Any,   r"^          (.+?)                 $"x) => Code()
        ]
            if state isa pattern_state
                m = match(pattern, line)
                m == nothing && continue
                state == next_state || leave(state, v)
                if state != next_state
                    state = next_state
                    push!(v, "")
                    enter(state, v, n)
                end
                if !isempty(m.captures)
                    push!(v, format(state, n, m[1]))
                end
                line = nothing
                break
            end
        end
        if line != nothing
            push!(v, line)
        end
    end
    leave(state, v)

    i = 1
    if v[i] == "---"
        i = 1 + findnext(isequal("---"), v, 2)
    end
#    f = basename(c_filename)
#    insert!(v, i, "")
#    insert!(v, i, "*Raw source: [`$f`]($(f)!)*")

    write(md_filename, join(v, "\n"))
end

c_to_md(ARGS[1])
