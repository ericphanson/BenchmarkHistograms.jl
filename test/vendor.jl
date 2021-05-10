# taken from <https://github.com/JuliaCI/BenchmarkTools.jl/blob/e058ff249215671c196f2c24a0a3f401de27b718/test/TrialsTests.jl#L177-L199>

@testset "Pretty printing" begin
    @test BenchmarkHistograms.prettypercent(.3120123) == "31.20%"

    @test BenchmarkHistograms.prettytime(999) == "999.000 ns"
    @test BenchmarkHistograms.prettytime(1000) == "1.000 μs"
    @test BenchmarkHistograms.prettytime(999_999) == "999.999 μs"
    @test BenchmarkHistograms.prettytime(1_000_000) == "1.000 ms"
    @test BenchmarkHistograms.prettytime(999_999_999) == "1000.000 ms"
    @test BenchmarkHistograms.prettytime(1_000_000_000) == "1.000 s"

    @test BenchmarkHistograms.prettymemory(1023) == "1023 bytes"
    @test BenchmarkHistograms.prettymemory(1024) == "1.00 KiB"
    @test BenchmarkHistograms.prettymemory(1048575) == "1024.00 KiB"
    @test BenchmarkHistograms.prettymemory(1048576) == "1.00 MiB"
    @test BenchmarkHistograms.prettymemory(1073741823) == "1024.00 MiB"
    @test BenchmarkHistograms.prettymemory(1073741824) == "1.00 GiB"
end
