using Literate
Literate.markdown(joinpath(@__DIR__, "README.jl"), outputdir="..", execute=true, documenter=false)
