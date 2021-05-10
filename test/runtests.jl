using BenchmarkHistograms
using Test
import BenchmarkTools


function counting_tests(nbins=nothing)
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
    # Corners of the plot
    @test n_matches(r"┌") == n_matches(r"┐") == n_matches(r"└") == n_matches(r"┘") == 1
    return nothing
end


function empty_test()
    bh = @benchmark 1+1
    empty!(bh.trial.times)
    output = sprint(show, MIME"text/plain"(), bh)

    # Don't want to test the exact string since the stats will
    # fluctuate. So let's just test that it contains the right
    # number of the right things, and assume they're arranged properly.
    n_matches = r -> length(collect(eachmatch(r, output)))

    @test n_matches(r"samples:") == 1
    @test n_matches(r"evals/sample:") == 1
    @test n_matches(r"memory estimate:") == 1
    @test n_matches(r"allocs estimate:") == 1
    @test n_matches(r"ns") == 0
    @test n_matches(r"Counts") == 0
    @test n_matches(r"min") == n_matches(r"mean") == n_matches(r"median") == n_matches(r"max") == 1
    @test n_matches(r"% GC") == 0
    @test n_matches(r"┌") == n_matches(r"┐") == n_matches(r"└") == n_matches(r"┘") == 0
    return nothing
end

function with_bins(f, nbins)
    pre = BenchmarkHistograms.NBINS[]
    BenchmarkHistograms.NBINS[] = nbins
    try
        f(nbins)
    finally
        BenchmarkHistograms.NBINS[] = pre
    end
    return nothing
end

@testset "BenchmarkHistograms.jl" begin
    @testset "Exports" begin
        @test symdiff(names(BenchmarkTools), names(BenchmarkHistograms)) == [:BenchmarkHistograms]
    end

    @testset "Counting tests" begin
        counting_tests()
        with_bins(counting_tests, 10)
        with_bins(counting_tests, -1)
        empty_test()
    end
end

# Macro hygiene test; done in global scope intentionally
f(x) = x+1
y=10
bh = @benchmark f($y)
@test bh isa BenchmarkHistograms.BenchmarkHistogram

include("vendor.jl")
