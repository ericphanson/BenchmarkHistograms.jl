module BenchmarkHistograms

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

export comparison

"""
    const NBINS = Ref(0)

Controls the number of histogram bins used.
When `NBINS[] <= 0`, the number is chosen automatically by Sturge's rule (i.e. `log2(length(data))+1`).
"""
const NBINS = Ref(0)

"""
    OUTLIER_QUANTILE = Ref(0.999)

Controls which benchmarking times count as outliers and may be grouped into a single bin.
Set `OUTLIER_QUANTILE[] = 1.0` to avoid this behavior.
"""
const OUTLIER_QUANTILE = Ref(0.999)

struct BenchmarkHistogram
    trial::BenchmarkTools.Trial
end

# borrowed some from `show` implementation for `BenchmarkTools.Trial`
function Base.show(io::IO, ::MIME"text/plain", bp::BenchmarkHistogram; nbins=NBINS[])
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
    if length(t) > 0
        bin_arg = nbins <= 0 ? NamedTuple() : (; nbins=nbins)
        simple_unicode_histogram(io, t.times; ylabel="ns", xlabel="Counts",
        outlier_quantile=OUTLIER_QUANTILE[], bin_arg...)
        println(io)
    end
    print(io, "min: ", minstr, "; mean: ", meanstr, "; median: ", medstr, "; max: ", maxstr, ".")
    return nothing
end

macro benchmark(exprs...)
    return esc(quote
        $BenchmarkHistogram($BenchmarkTools.@benchmark($(exprs...)))
    end)
end

# We vendor some pretty-printing methods from BenchmarkTools
# so that we don't have to rely on internals.
include("vendor.jl")

# The code to draw the histograms
include("simple_unicode_histogram.jl")

# Comparison plots
include("comparison.jl")

end
