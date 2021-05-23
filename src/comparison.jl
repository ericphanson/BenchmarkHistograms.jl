function comparison_histogram(io::IO, x::AbstractVector, y::AbstractVector;
                              nbins::Integer=ceil(Int, log2(min(length(x), length(y)))+1),
                              plot_width::Integer=30, show_counts::Bool=true,
                              outlier_quantile = 0.999,
                              xlabel="", ylabel="")

    bin_edges, truncate = get_edges([x; y]; nbins=nbins, outlier_quantile=outlier_quantile)
    hist_counts_x = get_counts(x, bin_edges; nbins=nbins, truncate=truncate)

    simple_unicode_histogram(io, bin_edges, hist_counts_x; plot_width=plot_width, show_counts=show_counts, xlabel="", ylabel=ylabel, truncate=truncate)
    hist_counts_y = get_counts(y, bin_edges; nbins=nbins, truncate=truncate)
    println(io)
    simple_unicode_histogram(io, bin_edges, hist_counts_y; plot_width=plot_width, show_counts=show_counts, xlabel=xlabel, ylabel=ylabel, truncate=truncate)
    return nothing
end

comparison(bench1::BenchmarkHistogram, bench2::BenchmarkHistogram; kwargs...) = comparison(stdout, bench1, bench2; kwargs...)

function comparison(io::IO, bench1::BenchmarkHistogram, bench2::BenchmarkHistogram; nbins::Integer=NBINS[],
    plot_width::Integer=30, show_counts::Bool=true,
    outlier_quantile = OUTLIER_QUANTILE[],
    xlabel="Counts", ylabel="")
    x = bench1.trial.times
    y = bench2.trial.times
    if nbins <= 0
        nbins = ceil(Int, log2(min(length(x), length(y)))+1)
    end
    return comparison_histogram(io, x, y; nbins=nbins, plot_width=plot_width, show_counts=show_counts, outlier_quantile=outlier_quantile, xlabel=xlabel, ylabel=ylabel)
end
