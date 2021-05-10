# [![CI](https://github.com/ericphanson/BenchmarkPlots.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ericphanson/BenchmarkPlots.jl/actions/workflows/CI.yml)
# [![codecov](https://codecov.io/gh/ericphanson/BenchmarkPlots.jl/branch/main/graph/badge.svg?token=v0aca89xRi)](https://codecov.io/gh/ericphanson/BenchmarkPlots.jl)

# # BenchmarkPlots

# Wraps [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) to provide a UnicodePlots.jl-powered `show` method for `@benchmark`. This is accomplished by a custom `@benchmark` method which wraps the output in a `BenchmarkPlot` struct with a custom show method.

# This means one should not call `using` on both BenchmarkPlots and BenchmarkTools in the same namespace, or else these `@benchmark` macros will conflict ("WARNING: using `BenchmarkTools.@benchmark` in module Main conflicts with an existing identifier.")

# However, BenchmarkPlots re-exports all the export of BenchmarkTools, so you can simply call `using BenchmarkPlots`.

# Providing this functionality in BenchmarkTools itself was discussed in <https://github.com/JuliaCI/BenchmarkTools.jl/pull/180>.

# Use the setting `BenchmarkPlots.NBINS[] = 10` to change the number of histogram bins used.

# ## Example

# One just uses `BenchmarkPlots` instead of `BenchmarkTools`, e.g.

using BenchmarkPlots

@benchmark sin(x) setup=(x=rand())

# That benchmark does not have a very interesting distribution, but it's not hard to find more interesting cases.

@benchmark 5 ∈ v setup=(v = sort(rand(1:10000, 10000)))

# Here, we see a bimodal distribution; in the case `5` is indeed in the vector, we find it very quickly, in the 0-1000 ns range (thanks to `sort` which places it at the front). In the case 5 is not present, we need to check every entry to be sure, and we end up in the 3000-4000 ns range.

# Without the `sort`, we end up with more of a uniform distribution:

@benchmark 5 ∈ v setup=(v = rand(1:10000, 10000))


# This function gives a nice Gaussian distribution of times, kindly supplied by Mason Protter:

f() = sum((sin(i) for i in 1:round(Int, 1000 + 100*randn())))

@benchmark f()


# See also <https://tratt.net/laurie/blog/entries/minimum_times_tend_to_mislead_when_benchmarking.html> for another example of where looking at the whole histogram can be useful in benchmarking.
