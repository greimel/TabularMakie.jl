using TabularMakie
using Documenter

makedocs(;
    modules=[TabularMakie],
    authors="Fabian Greimel <fabgrei@gmail.com> and contributors",
    repo="https://github.com/greimel/TabularMakie.jl/blob/{commit}{path}#L{line}",
    sitename="TabularMakie.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://greimel.github.io/TabularMakie.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo = "github.com/greimel/TabularMakie.jl",
    devbranch = "main",
    push_preview = true,
)
