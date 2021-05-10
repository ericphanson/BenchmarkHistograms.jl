[![CI](https://github.com/ericphanson/BenchmarkHistograms.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ericphanson/BenchmarkHistograms.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/ericphanson/BenchmarkHistograms.jl/branch/main/graph/badge.svg?token=v0aca89xRi)](https://codecov.io/gh/ericphanson/BenchmarkHistograms.jl)

# BenchmarkHistograms

Wraps [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) to provide a UnicodePlots.jl-powered `show` method for `@benchmark`. This is accomplished by a custom `@benchmark` method which wraps the output in a `BenchmarkPlot` struct with a custom show method.

This means one should not call `using` on both BenchmarkHistograms and BenchmarkTools in the same namespace, or else these `@benchmark` macros will conflict ("WARNING: using `BenchmarkTools.@benchmark` in module Main conflicts with an existing identifier.")

However, BenchmarkHistograms re-exports all of BenchmarkTools (including the module `BenchmarkTools` itself), so you can simply call `using BenchmarkHistograms` instead.

Providing this functionality in BenchmarkTools itself was discussed in <https://github.com/JuliaCI/BenchmarkTools.jl/pull/180>.

Use the setting `BenchmarkHistograms.NBINS[]` to change the number of histogram bins used, e.g.
```julia
BenchmarkHistograms.NBINS[] = 10
```
to use 10 bins.

## Example

One just uses `BenchmarkHistograms` instead of `BenchmarkTools`, e.g.

```julia
using BenchmarkHistograms

@benchmark sin(x) setup=(x=rand())
```

```
samples: 10000; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                   ┌                                        ┐ 
      [ 4.0,  6.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 7823   
      [ 6.0,  8.0) ┤▇▇▇▇▇▇▇ 1643                              
      [ 8.0, 10.0) ┤▇▇ 529                                    
      [10.0, 12.0) ┤ 2                                        
      [12.0, 14.0) ┤ 2                                        
   ns [14.0, 16.0) ┤ 0                                        
      [16.0, 18.0) ┤ 0                                        
      [18.0, 20.0) ┤ 0                                        
      [20.0, 22.0) ┤ 0                                        
      [22.0, 24.0) ┤ 0                                        
      [24.0, 26.0) ┤ 0                                        
      [26.0, 28.0) ┤ 1                                        
                   └                                        ┘ 
                                    Counts
min: 4.916 ns (0.00% GC); mean: 5.724 ns (0.00% GC); median: 5.208 ns (0.00% GC); max: 27.458 ns (0.00% GC).
```

That benchmark does not have a very interesting distribution, but it's not hard to find more interesting cases.

```julia
@benchmark 5 ∈ v setup=(v = sort(rand(1:10000, 10000)))
```

```
samples: 3192; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                       ┌                                        ┐ 
      [   0.0,  500.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 2036   
      [ 500.0, 1000.0) ┤ 0                                        
      [1000.0, 1500.0) ┤ 0                                        
   ns [1500.0, 2000.0) ┤ 0                                        
      [2000.0, 2500.0) ┤ 0                                        
      [2500.0, 3000.0) ┤ 0                                        
      [3000.0, 3500.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1156                  
                       └                                        ┘ 
                                        Counts
min: 1.875 ns (0.00% GC); mean: 1.141 μs (0.00% GC); median: 4.521 ns (0.00% GC); max: 3.315 μs (0.00% GC).
```

Here, we see a bimodal distribution; in the case `5` is indeed in the vector, we find it very quickly, in the 0-1000 ns range (thanks to `sort` which places it at the front). In the case 5 is not present, we need to check every entry to be sure, and we end up in the 3000-4000 ns range.

Without the `sort`, we end up with more of a uniform distribution:

```julia
@benchmark 5 ∈ v setup=(v = rand(1:10000, 10000))
```

```
samples: 2461; evals/sample: 999; memory estimate: 0 bytes; allocs estimate: 0
                       ┌                                        ┐ 
      [   0.0,  500.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 364                        
      [ 500.0, 1000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇ 327                          
      [1000.0, 1500.0) ┤▇▇▇▇▇▇▇▇▇▇ 266                            
   ns [1500.0, 2000.0) ┤▇▇▇▇▇▇▇▇ 214                              
      [2000.0, 2500.0) ┤▇▇▇▇▇▇▇▇ 213                              
      [2500.0, 3000.0) ┤▇▇▇▇▇ 146                                 
      [3000.0, 3500.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 931   
                       └                                        ┘ 
                                        Counts
min: 8.842 ns (0.00% GC); mean: 1.972 μs (0.00% GC); median: 2.154 μs (0.00% GC); max: 3.364 μs (0.00% GC).
```

This function gives a somewhat more Gaussian distribution of times, kindly supplied by Mason Protter:

```julia
f() = sum((sin(i) for i in 1:round(Int, 1000 + 100*randn())))

@benchmark f()
```

```
samples: 10000; evals/sample: 3; memory estimate: 0 bytes; allocs estimate: 0
                           ┌                                        ┐ 
      [     0.0,  20000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 9978   
      [ 20000.0,  40000.0) ┤ 16                                       
      [ 40000.0,  60000.0) ┤ 3                                        
      [ 60000.0,  80000.0) ┤ 0                                        
      [ 80000.0, 100000.0) ┤ 1                                        
      [100000.0, 120000.0) ┤ 1                                        
      [120000.0, 140000.0) ┤ 0                                        
      [140000.0, 160000.0) ┤ 0                                        
   ns [160000.0, 180000.0) ┤ 0                                        
      [180000.0, 200000.0) ┤ 0                                        
      [200000.0, 220000.0) ┤ 0                                        
      [220000.0, 240000.0) ┤ 0                                        
      [240000.0, 260000.0) ┤ 0                                        
      [260000.0, 280000.0) ┤ 0                                        
      [280000.0, 300000.0) ┤ 0                                        
      [300000.0, 320000.0) ┤ 0                                        
      [320000.0, 340000.0) ┤ 1                                        
                           └                                        ┘ 
                                            Counts
min: 6.889 μs (0.00% GC); mean: 9.161 μs (0.00% GC); median: 9.014 μs (0.00% GC); max: 327.208 μs (0.00% GC).
```

See also <https://tratt.net/laurie/blog/entries/minimum_times_tend_to_mislead_when_benchmarking.html> for another example of where looking at the whole histogram can be useful in benchmarking.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
