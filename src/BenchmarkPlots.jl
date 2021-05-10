module BenchmarkPlots

using UnicodePlots
using Statistics
using Printf
using BenchmarkTools: BenchmarkTools

# Reexport everything *except* `@benchmark`
for T in setdiff(names(BenchmarkTools), tuple(Symbol("@benchmark")))
    @eval begin
        using BenchmarkTools: $T
        export $T
    end
end

# Export our own `@benchmark`
export @benchmark

"""
    const NBINS = Ref(0)

Controls the number of histogram bins used.
When `NBINS[] <= 0`, the number is chosen automatically by UnicodePlots.
"""
const NBINS = Ref(0)

struct BenchmarkPlot
    trial::BenchmarkTools.Trial
end

# borrowed some from `show` implementation for `BenchmarkTools.Trial`
function Base.show(io::IO, ::MIME"text/plain", bp::BenchmarkPlot)
    t = bp.trial
    if length(t) > 0
        min = minimum(t)
        max = maximum(t)
        med = median(t)
        avg = mean(t)
        memorystr = string(prettymemory(memory(min)))
        allocsstr = string(allocs(min))
        minstr = string(prettytime(time(min)), " (", prettypercent(gcratio(min)), " GC)")
        maxstr = string(prettytime(time(max)), " (", prettypercent(gcratio(max)), " GC)")
        medstr = string(prettytime(time(med)), " (", prettypercent(gcratio(med)), " GC)")
        meanstr = string(prettytime(time(avg)), " (", prettypercent(gcratio(avg)), " GC)")
    else
        memorystr = "N/A"
        allocsstr = "N/A"
        minstr = "N/A"
        maxstr = "N/A"
        medstr = "N/A"
        meanstr = "N/A"
    end
    println(io, "samples: ", length(t), "; evals/sample: ", t.params.evals, "; memory estimate: ", memorystr, "; allocs estimate: ", allocsstr)

    bin_arg = NBINS[] <= 0 ? NamedTuple() : (; nbins=NBINS[])
    show(io, histogram(t.times; ylabel="ns", xlabel="Counts", bin_arg...))
    println(io)
    print(io, "min: ", minstr, "; mean: ", meanstr, "; median: ", medstr, "; max: ", maxstr, ".")
end

macro benchmark(exprs...)
    return quote
        BenchmarkPlot(BenchmarkTools.@benchmark($(exprs...)))
    end
end

# We vendor some pretty-printing methods from BenchmarkTools
# so that we don't have to rely on internals.
include("vendor.jl")

end
