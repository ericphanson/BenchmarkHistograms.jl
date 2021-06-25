[![CI](https://github.com/ericphanson/BenchmarkHistograms.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ericphanson/BenchmarkHistograms.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/ericphanson/BenchmarkHistograms.jl/branch/main/graph/badge.svg?token=v0aca89xRi)](https://codecov.io/gh/ericphanson/BenchmarkHistograms.jl)

# BenchmarkHistograms

## Note: BenchmarkTools [now](https://github.com/JuliaCI/BenchmarkTools.jl/pull/217) prints very pretty histograms automatically for `@benchmark`. This package is therefore obsolete.

Wraps [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) to provide a unicode histogram `show` method for `@benchmark`. This is accomplished by a custom `@benchmark` method which wraps the output in a `BenchmarkPlot` struct with a custom show method.

This means one should not call `using` on both BenchmarkHistograms and BenchmarkTools in the same namespace, or else these `@benchmark` macros will conflict ("WARNING: using `BenchmarkTools.@benchmark` in module Main conflicts with an existing identifier.")

However, BenchmarkHistograms re-exports all the export of BenchmarkTools, so you can simply call `using BenchmarkHistograms`.

Providing this functionality in BenchmarkTools itself was discussed in <https://github.com/JuliaCI/BenchmarkTools.jl/pull/180>.
Thanks to @brenhinkeller for providing the initial plotting code there.

Use the setting `BenchmarkHistograms.NBINS` to change the number of histogram bins used, e.g. `BenchmarkHistograms.NBINS[] = 10` for 10 bins.

Likewise use the setting `BenchmarkHistograms.OUTLIER_QUANTILE` to tweak which values count as outliers and may be grouped into a single bin.
For example, `BenchmarkHistograms.OUTLIER_QUANTILE[] = 0.99` counts any values past the 99 percentile as possible outliers. This value defaults to `0.999` and is disabled by setting it to `1.0`.

## Example

One just uses `BenchmarkHistograms` instead of `BenchmarkTools`, e.g.

```julia
using BenchmarkHistograms

@benchmark sin(x) setup=(x=rand())
```

```
samples: 10000; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
ns

 (8.04  - 8.53 ]  ██████████████████████████████▏7673
 (8.53  - 9.02 ]  ▌109
 (9.02  - 9.51 ]  ▏3
 (9.51  - 10.01]   0
 (10.01 - 10.5 ]   0
 (10.5  - 10.99]  █████▋1431
 (10.99 - 11.48]  ██▌624
 (11.48 - 11.97]  ▍70
 (11.97 - 12.46]  ▎38
 (12.46 - 12.95]  ▏4
 (12.95 - 13.44]  ▏1
 (13.44 - 13.93]  ▏2
 (13.93 - 14.42]  ▏7
 (14.42 - 14.92]  ▏22
 (14.92 - 21.88]  ▏16

                  Counts

min: 8.041 ns (0.00% GC); mean: 8.812 ns (0.00% GC); median: 8.166 ns (0.00% GC); max: 21.875 ns (0.00% GC).
```

That benchmark does not have a very interesting distribution, but it's not hard to find more interesting cases.

```julia
@benchmark 5 ∈ v setup=(v = sort(rand(1:10000, 10000)))
```

```
samples: 3110; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
ns

 (0.0    - 280.0 ]  ██████████████████████████████ 1964
 (280.0  - 570.0 ]   0
 (570.0  - 850.0 ]   0
 (850.0  - 1130.0]   0
 (1130.0 - 1410.0]   0
 (1410.0 - 1690.0]   0
 (1690.0 - 1970.0]   0
 (1970.0 - 2250.0]   0
 (2250.0 - 2540.0]   0
 (2540.0 - 2820.0]   0
 (2820.0 - 3100.0]   0
 (3100.0 - 3380.0]  █████████████████1105
 (3380.0 - 3660.0]  ▊41

                  Counts

min: 2.500 ns (0.00% GC); mean: 1.181 μs (0.00% GC); median: 5.334 ns (0.00% GC); max: 3.663 μs (0.00% GC).
```

Here, we see a bimodal distribution; in the case `5` is indeed in the vector, we find it very quickly, in the 0-1000 ns range (thanks to `sort` which places it at the front). In the case 5 is not present, we need to check every entry to be sure, and we end up in the 3000-4000 ns range.

Without the `sort`, we end up with more of a uniform distribution:

```julia
@benchmark 5 ∈ v setup=(v = rand(1:10000, 10000))
```

```
samples: 2393; evals/sample: 1000; memory estimate: 0 bytes; allocs estimate: 0
ns

 (0.0    - 310.0 ]  ███████▏214
 (310.0  - 610.0 ]  ██████▍191
 (610.0  - 910.0 ]  █████▊173
 (910.0  - 1220.0]  █████▊174
 (1220.0 - 1520.0]  █████▏155
 (1520.0 - 1830.0]  ████▍133
 (1830.0 - 2130.0]  ████119
 (2130.0 - 2430.0]  ███▍100
 (2430.0 - 2740.0]  ██▉86
 (2740.0 - 3040.0]  ███▍102
 (3040.0 - 3350.0]  ██████████████████████████████ 912
 (3350.0 - 3650.0]  █30
 (3650.0 - 5870.0]  ▎4

                  Counts

min: 2.334 ns (0.00% GC); mean: 2.037 μs (0.00% GC); median: 2.236 μs (0.00% GC); max: 5.869 μs (0.00% GC).
```

This function gives a somewhat more Gaussian distribution of times, kindly supplied by Mason Protter:

```julia
f() = sum((sin(i) for i in 1:round(Int, 1000 + 100*randn())))

@benchmark f()
```

```
samples: 10000; evals/sample: 3; memory estimate: 0 bytes; allocs estimate: 0
ns

 (7030.0  - 7480.0 ]  ▏11
 (7480.0  - 7930.0 ]  █▍128
 (7930.0  - 8380.0 ]  ████████▏788
 (8380.0  - 8830.0 ]  █████████████████████▏2044
 (8830.0  - 9280.0 ]  ██████████████████████████████ 2916
 (9280.0  - 9730.0 ]  ███████████████████████▉2309
 (9730.0  - 10180.0]  ████████████▎1182
 (10180.0 - 10630.0]  ████▎413
 (10630.0 - 11080.0]  █▌140
 (11080.0 - 11530.0]  ▌44
 (11530.0 - 11980.0]  ▏6
 (11980.0 - 12430.0]  ▏3
 (12430.0 - 12880.0]   0
 (12880.0 - 13330.0]  ▏5
 (13330.0 - 18330.0]  ▏11

                  Counts

min: 7.028 μs (0.00% GC); mean: 9.184 μs (0.00% GC); median: 9.153 μs (0.00% GC); max: 18.333 μs (0.00% GC).
```

See also <https://tratt.net/laurie/blog/entries/minimum_times_tend_to_mislead_when_benchmarking.html> for another example of where looking at the whole histogram can be useful in benchmarking.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

