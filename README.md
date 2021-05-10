[![CI](https://github.com/ericphanson/BenchmarkPlots.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ericphanson/BenchmarkPlots.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/ericphanson/BenchmarkPlots.jl/branch/main/graph/badge.svg?token=v0aca89xRi)](https://codecov.io/gh/ericphanson/BenchmarkPlots.jl)

# BenchmarkPlots

Wraps [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) to provide a UnicodePlots.jl-powered `show` method for `@benchmark`. This is accomplished by a custom `@benchmark` method which wraps the output in a `BenchmarkPlot` struct with a custom show method.

This means one should not call `using` on both BenchmarkPlots and BenchmarkTools in the same namespace, or else these `@benchmark` macros will conflict ("WARNING: using `BenchmarkTools.@benchmark` in module Main conflicts with an existing identifier.")

However, BenchmarkPlots re-exports all the export of BenchmarkTools, so you can simply call `using BenchmarkPlots`.

Providing this functionality in BenchmarkTools itself was discussed in <https://github.com/JuliaCI/BenchmarkTools.jl/pull/180>.

Use the setting `BenchmarkPlots.NBINS[] = 10` to change the number of histogram bins used.

## Example

One just uses `BenchmarkPlots` instead of `BenchmarkTools`, e.g.

```julia
using BenchmarkPlots

@benchmark sin(x) setup=(x=rand())
```

```
samples: 10000; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                   ┌                                        ┐ 
      [ 4.0,  6.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 7802   
      [ 6.0,  8.0) ┤▇▇▇▇▇▇▇▇▇ 2025                            
      [ 8.0, 10.0) ┤▇ 137                                     
      [10.0, 12.0) ┤ 5                                        
      [12.0, 14.0) ┤ 2                                        
      [14.0, 16.0) ┤ 5                                        
      [16.0, 18.0) ┤ 4                                        
      [18.0, 20.0) ┤ 7                                        
   ns [20.0, 22.0) ┤ 8                                        
      [22.0, 24.0) ┤ 1                                        
      [24.0, 26.0) ┤ 2                                        
      [26.0, 28.0) ┤ 0                                        
      [28.0, 30.0) ┤ 0                                        
      [30.0, 32.0) ┤ 0                                        
      [32.0, 34.0) ┤ 1                                        
      [34.0, 36.0) ┤ 0                                        
      [36.0, 38.0) ┤ 1                                        
                   └                                        ┘ 
                                    Counts
min: 4.916 ns (0.00% GC); mean: 5.656 ns (0.00% GC); median: 5.042 ns (0.00% GC); max: 36.833 ns (0.00% GC).
```

That benchmark does not have a very interesting distribution, but it's not hard to find more interesting cases.

```julia
@benchmark 5 ∈ v setup=(v = sort(rand(1:10000, 10000)))
```

```
samples: 3116; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                         ┌                                        ┐ 
      [    0.0,  1000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1966   
      [ 1000.0,  2000.0) ┤ 0                                        
      [ 2000.0,  3000.0) ┤ 0                                        
      [ 3000.0,  4000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1146                 
      [ 4000.0,  5000.0) ┤ 1                                        
   ns [ 5000.0,  6000.0) ┤ 2                                        
      [ 6000.0,  7000.0) ┤ 0                                        
      [ 7000.0,  8000.0) ┤ 0                                        
      [ 8000.0,  9000.0) ┤ 0                                        
      [ 9000.0, 10000.0) ┤ 0                                        
      [10000.0, 11000.0) ┤ 0                                        
      [11000.0, 12000.0) ┤ 1                                        
                         └                                        ┘ 
                                          Counts
min: 1.875 ns (0.00% GC); mean: 1.182 μs (0.00% GC); median: 4.708 ns (0.00% GC); max: 11.071 μs (0.00% GC).
```

Here, we see a bimodal distribution; in the case `5` is indeed in the vector, we find it very quickly, in the 0-1000 ns range (thanks to `sort` which places it at the front). In the case 5 is not present, we need to check every entry to be sure, and we end up in the 3000-4000 ns range.

Without the `sort`, we end up with more of a uniform distribution:

```julia
@benchmark 5 ∈ v setup=(v = rand(1:10000, 10000))
```

```
samples: 2410; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                         ┌                                        ┐ 
      [    0.0,  1000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 633              
      [ 1000.0,  2000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 493                    
      [ 2000.0,  3000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇ 342                         
      [ 3000.0,  4000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 940   
      [ 4000.0,  5000.0) ┤ 0                                        
      [ 5000.0,  6000.0) ┤ 1                                        
   ns [ 6000.0,  7000.0) ┤ 0                                        
      [ 7000.0,  8000.0) ┤ 0                                        
      [ 8000.0,  9000.0) ┤ 0                                        
      [ 9000.0, 10000.0) ┤ 0                                        
      [10000.0, 11000.0) ┤ 0                                        
      [11000.0, 12000.0) ┤ 0                                        
      [12000.0, 13000.0) ┤ 1                                        
                         └                                        ┘ 
                                          Counts
min: 5.709 ns (0.00% GC); mean: 2.025 μs (0.00% GC); median: 2.185 μs (0.00% GC); max: 12.989 μs (0.00% GC).
```

This function gives a nice Gaussian distribution of times, kindly supplied by Mason Protter:

```julia
f() = sum((sin(i) for i in 1:round(Int, 1000 + 100*randn())))

@benchmark f()
```

```
samples: 10000; evals/sample: 4; memory estimate: 0 bytes; allocs estimate: 0
                         ┌                                        ┐ 
      [ 6000.0,  7000.0) ┤ 49                                       
      [ 7000.0,  8000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 4770     
      [ 8000.0,  9000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 5016   
      [ 9000.0, 10000.0) ┤▇ 142                                     
   ns [10000.0, 11000.0) ┤ 4                                        
      [11000.0, 12000.0) ┤ 4                                        
      [12000.0, 13000.0) ┤ 3                                        
      [13000.0, 14000.0) ┤ 8                                        
      [14000.0, 15000.0) ┤ 4                                        
                         └                                        ┘ 
                                          Counts
min: 6.396 μs (0.00% GC); mean: 8.033 μs (0.00% GC); median: 8.011 μs (0.00% GC); max: 14.896 μs (0.00% GC).
```

See also <https://tratt.net/laurie/blog/entries/minimum_times_tend_to_mislead_when_benchmarking.html> for another example of where looking at the whole histogram can be useful in benchmarking.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
