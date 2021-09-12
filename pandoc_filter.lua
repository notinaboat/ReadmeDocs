function Link(el)

    -- print(pandoc.utils.stringify(el.content).." -> "..el.target)

    -- Expand links to relative URIs. e.g. [`../local_file.md`](@uri)
    if el.target == "@uri" then
        text = pandoc.utils.stringify(el.content)
        el.target = string.gsub(text, "`", "")
    end

    -- If the link target is a full URI leave it alone.
    if string.find(el.target, "://") then
        return el
    end

    -- Convert links to `.md.` files to `.html`.
    el.target = string.gsub(el.target, "%.md$", ".md.html")
    el.target = string.gsub(el.target, "%.md#(.*)$", ".md.html#%1")
    el.target = string.gsub(el.target, "%.h$", ".h.md.html")
    el.target = string.gsub(el.target, "%.c$", ".c.md.html")
    el.target = string.gsub(el.target, "%.jl$", ".jl.html")
    el.target = string.gsub(el.target, "%.sh$", ".sh.html")
    el.target = string.gsub(el.target, "%.lua$", ".lua.html")
    el.target = string.gsub(el.target, "%.txt$", ".txt.html")
    el.target = string.gsub(el.target, "%.shared$", ".shared.html")
    el.target = string.gsub(el.target, "%Makefile$", "Makefile.html")
    el.target = string.gsub(el.target, "%/$", "/README.html")

    el.target = string.gsub(el.target, "%!", "")

    -- Expand links to GitHub issues.
    if el.target == "@jl#" then
        n = pandoc.utils.stringify(el.content)
        el.target = "https://github.com/JuliaLang/julia/issues/"..n
    end
    if el.target == "@uv#" then
        n = pandoc.utils.stringify(el.content)
        el.target = "https://github.com/libuv/libuv/issues/"..n
    end

    return el
end
