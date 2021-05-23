using BenchmarkHistograms
using Test
import BenchmarkTools

block_regex = Regex(string("(", join(BenchmarkHistograms.BLOCKS[2:end], "|"), string(")")))

function counting_tests(nbins=nothing, outlier_quantile=nothing)
    bh = @benchmark 1+1
    output = sprint(show, MIME"text/plain"(), bh)

    # Don't want to test the exact string since the stats will
    # fluctuate. So let's just test that it contains the right
    # number of the right things, and assume they're arranged properly.
    n_matches = r -> length(collect(eachmatch(r, output)))

    # Top row: timing stats
    @test n_matches(r"samples:") == 1
    @test n_matches(r"evals/sample:") == 1
    @test n_matches(r"memory estimate:") == 1
    @test n_matches(r"allocs estimate:") == 1
    # y-axis label + at most four summary stats
    @test 1 <= n_matches(r"ns") <= 5
    @test n_matches(r"Counts") == 1
    # Summary stats
    @test n_matches(r"min") == n_matches(r"mean") == n_matches(r"median") == n_matches(r"max") == 1
    @test n_matches(r"% GC") == 4

    # Bars of the plot
    @test n_matches(block_regex) > 1
    return nothing
end


function empty_test()
    bh = @benchmark 1+1
    empty!(bh.trial.times)
    output = sprint(show, MIME"text/plain"(), bh)

    n_matches = r -> length(collect(eachmatch(r, output)))

    @test n_matches(r"samples:") == 1
    @test n_matches(r"evals/sample:") == 1
    @test n_matches(r"memory estimate:") == 1
    @test n_matches(r"allocs estimate:") == 1
    @test n_matches(r"ns") == 0
    @test n_matches(r"Counts") == 0
    @test n_matches(r"min") == n_matches(r"mean") == n_matches(r"median") == n_matches(r"max") == 1
    @test n_matches(r"% GC") == 0
    # Bars of the plot
    @test n_matches(block_regex) == 0
    return nothing
end

function with_params(f, nbins, outlier_quantile)
    pre_bins = BenchmarkHistograms.NBINS[]
    pre_q = BenchmarkHistograms.OUTLIER_QUANTILE[]
    BenchmarkHistograms.NBINS[] = nbins
    BenchmarkHistograms.OUTLIER_QUANTILE[] = outlier_quantile
    try
        f(nbins, outlier_quantile)
    finally
        BenchmarkHistograms.NBINS[] = pre_bins
        BenchmarkHistograms.OUTLIER_QUANTILE[] = pre_q
    end
    return nothing
end

@testset "BenchmarkHistograms.jl" begin
    @testset "Exports" begin
        @test symdiff(names(BenchmarkTools), names(BenchmarkHistograms)) == [:BenchmarkHistograms, :comparison]
    end

    @testset "Counting tests" begin
        counting_tests()
        # we don't actually test that changing the parameters
        # does something, but we at least test that we can
        # change them to some different values without getting errors.
        with_params(counting_tests, 10, 0.99)
        with_params(counting_tests, -1, 1.0)
        empty_test()
    end
end

# Macro hygiene test; done in global scope intentionally
f(x) = x+1
y=10
bh = @benchmark f($y)
@test bh isa BenchmarkHistograms.BenchmarkHistogram

include("vendor.jl")
