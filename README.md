# BenchmarkPlots

Wraps [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) to provide a UnicodePlots.jl-powered `show` method for `@benchmark`. This is accomplished by a custom `@benchmark` method which wraps the output in a `BenchmarkPlot` struct with a custom show method.

This means one should not call `using` on both BenchmarkPlots and BenchmarkTools in the same namespace, or else these `@benchmark` macros will conflict ("WARNING: using `BenchmarkTools.@benchmark` in module Main conflicts with an existing identifier.")

However, BenchmarkPlots re-exports all the export of BenchmarkTools, so you can simply call `using BenchmarkPlots`.

## Example

One just uses `BenchmarkPlots` instead of `BenchmarkTools`, e.g.
```julia
julia> using BenchmarkPlots

julia> @benchmark sin(x) setup=(x=rand())
samples: 10000; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                   ┌                                        ┐ 
      [ 0.0,  5.0) ┤ 131                                      
      [ 5.0, 10.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 9848   
   ns [10.0, 15.0) ┤ 18                                       
      [15.0, 20.0) ┤ 2                                        
      [20.0, 25.0) ┤ 1                                        
                   └                                        ┘ 
                                    Counts
min: 4.917 ns (0.00% GC); mean: 5.578 ns (0.00% GC); median: 5.042 ns (0.00% GC); max: 22.375 ns (0.00% GC).
```
That benchmark does not have a very interesting distribution, but it's not hard to find more interesting cases.

```julia
julia> @benchmark 5 ∈ v setup=(v = sort(rand(1:10000, 10000)))
samples: 3169; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                       ┌                                        ┐ 
      [   0.0, 1000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 2020   
   ns [1000.0, 2000.0) ┤ 0                                        
      [2000.0, 3000.0) ┤ 0                                        
      [3000.0, 4000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1149                  
                       └                                        ┘ 
                                        Counts
min: 1.875 ns (0.00% GC); mean: 1.152 μs (0.00% GC); median: 4.708 ns (0.00% GC); max: 3.588 μs (0.00% GC).
```
Here, we see a bimodal distribution; in the case `5` is indeed in the vector, we find it very quickly, in the 0-1000 ns range (thanks to `sort` which places it at the front). In the case 5 is not present, we need to check every entry to be sure, and we end up in the 3000-4000 ns range.

Without the `sort`, we end up with more of a uniform distribution:
```julia
julia> @benchmark 5 ∈ v setup=(v = rand(1:10000, 10000))
samples: 2379; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
                       ┌                                        ┐ 
      [   0.0, 1000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 619               
   ns [1000.0, 2000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 458                     
      [2000.0, 3000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇ 356                         
      [3000.0, 4000.0) ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 946   
                       └                                        ┘ 
                                        Counts
min: 1.917 ns (0.00% GC); mean: 2.040 μs (0.00% GC); median: 2.257 μs (0.00% GC); max: 3.552 μs (0.00% GC).
```
