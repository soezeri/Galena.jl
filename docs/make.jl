using Documenter
using Galena

makedocs()

deploydocs(
    deps = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/ffreyer/Galena.jl.git",
    julia = "0.6",
    osname = "linux"
)
