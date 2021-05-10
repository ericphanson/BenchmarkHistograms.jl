using BenchmarkPlots
using Test

function tests()
    bp = @benchmark 1+1
    output = sprint(show, MIME"text/plain"(), bp)

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

function tests(nbins)
    pre = BenchmarkPlots.NBINS[]
    BenchmarkPlots.NBINS[] = nbins
    try
        tests()
    finally
        BenchmarkPlots.NBINS[] = pre
    end
    return nothing
end

@testset "BenchmarkPlots.jl" begin
    tests()
    tests(10)
    tests(-1)
end
