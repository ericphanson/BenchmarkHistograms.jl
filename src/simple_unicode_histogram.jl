# Modified from https://github.com/JuliaCI/BenchmarkTools.jl/pull/180#issuecomment-711128281 by @brenhinkeller

const BLOCKS = [" ","▏","▎","▍","▌","▋","▊","▉","█","█"]

function get_edges(x; nbins, outlier_quantile)
    # Find bounds. Our naive attempt is to use equal width
    # bins from the minimum to the maximum.
    l, M = extrema(x)
    initial_dx = (M - l) / nbins

    # Now, we check: if we don't have some big outliers, we'd expect
    # the 99.9 percentile, `Q`, to be within a few bins of the maximum.
    # Here, we choose 2. If it is not, then we decide that indeed
    # there are outliers. We will instead divide the range from
    # the minimum to `Q` equally with `nbins-1` bins, and then reserve
    # the last bin to hold everything greater than `Q`.
    Q = quantile(x, outlier_quantile)
    truncate = M - Q > 2*initial_dx

    # our "upper bound"
    u = truncate ? Q : M

    if truncate
        bin_edges = [range(l;stop=u,length=nbins); M]
    else
        bin_edges = range(l;stop=u,length=nbins+1)
    end
    return bin_edges, truncate
end

function get_counts(x, bin_edges; nbins, truncate)
    u = truncate ? bin_edges[end-1] : bin_edges[end]
    l = bin_edges[1]

    # Fill histogram
    hist_counts = fill(0, nbins)
    dx = truncate ? (u - l) / (nbins - 1) : (u - l) / nbins
    for xi in x
        index = ceil(Int, (xi - l) / dx)
        if 1 <= index <= nbins
            hist_counts[index] += 1
        else
            hist_counts[end] += 1
        end
    end
    return hist_counts
end

function simple_unicode_histogram(io::IO, x::AbstractVector;
                                  nbins::Integer=ceil(Int, log2(length(x))+1),
                                  plot_width::Integer=30, show_counts::Bool=true,
                                  outlier_quantile = 0.999,
                                  xlabel="", ylabel="")
    
    bin_edges, truncate = get_edges(x; nbins, outlier_quantile)
    hist_counts = get_counts(x, bin_edges; nbins, truncate)
    return simple_unicode_histogram(io, bin_edges, hist_counts; plot_width, show_counts, xlabel, ylabel, truncate)
end

function simple_unicode_histogram(io::IO, bin_edges::AbstractVector, hist_counts::AbstractVector;
        plot_width::Integer=30, show_counts::Bool=true,
        xlabel="", ylabel="", truncate=true)
    nbins = length(bin_edges) - 1
    l = first(bin_edges)
    u = truncate ? bin_edges[end-1] : bin_edges[end]
    d = ceil(Int, -log10(u-l))+1
    scale = plot_width/maximum(hist_counts)
    lower_labels = string.(round.(bin_edges[1:end-1], digits=d+ceil(Int,log10(nbins)-1)))
    upper_labels = string.(round.(bin_edges[2:end], digits=d+ceil(Int,log10(nbins)-1)))
    longest_lower = maximum(length.(lower_labels))
    longest_upper = maximum(length.(upper_labels))
    !isempty(ylabel) && println(io, ylabel, "\n")
    for i=1:nbins
        nblocks = hist_counts[i] * scale
        block_string = repeat("█", floor(Int, nblocks)) * BLOCKS[ceil(Int,(nblocks - floor(nblocks))*8)+1]
        print(io, " (", lower_labels[i], " "^(longest_lower - length(lower_labels[i])))
        print(io, " - ", upper_labels[i], " "^(longest_upper - length(upper_labels[i])), "]  ")
        printstyled(io, block_string; color=:green)
        if show_counts
            print(io, hist_counts[i])
        end
        println(io)
    end
    isempty(xlabel) || println(io, "\n", " "^max(plot_width ÷2 + 6 - length(xlabel)÷2, 0), xlabel)
    return nothing
end
