# Modified from https://github.com/JuliaCI/BenchmarkTools.jl/pull/180#issuecomment-711128281
function simple_unicode_histogram(io::IO, x::AbstractArray; nbins::Integer=ceil(Int, log2(length(x))+1), plotwidth::Integer=30, showcounts::Bool=true, xlabel="", ylabel="")
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
    Q = quantile(x, 0.999)
    truncate = M - Q > 2*initial_dx

    # our "upper bound"
    u = truncate ? Q : M

    # Fill histogram
    histcounts = fill(0, nbins)
    dx = truncate ? (u - l) / (nbins - 1) : initial_dx
    for xi in x
        index = ceil(Int, (xi - l) / dx)
        if 1 <= index <= nbins
            histcounts[index] += 1
        else
            histcounts[end] += 1
        end
    end

    if truncate
        binedges = [range(l,u,length=nbins); M]
    else
        binedges = range(l,u,length=nbins+1)
    end

    # Print the histogram
    digitsneeded = ceil(Int, -log10(u-l))+1
    blocks = [" ","▏","▎","▍","▌","▋","▊","▉","█","█"]
    scale = plotwidth/maximum(histcounts)
    lowerlabels = string.(round.(binedges[1:end-1], digits=digitsneeded+ceil(Int,log10(nbins)-1)))
    upperlabels = string.(round.(binedges[2:end], digits=digitsneeded+ceil(Int,log10(nbins)-1)))
    longestlower = maximum(length.(lowerlabels))
    longestupper = maximum(length.(upperlabels))
    !isempty(ylabel) && println(io, ylabel, "\n")
    for i=1:nbins
        nblocks = histcounts[i] * scale
        blockstring = repeat("█", floor(Int, nblocks)) * blocks[ceil(Int,(nblocks - floor(nblocks))*8)+1]
        print(io, " (", lowerlabels[i], " "^(longestlower - length(lowerlabels[i])))
        print(io, " - ", upperlabels[i], " "^(longestupper - length(upperlabels[i])), "]  ")
        printstyled(io, blockstring; color=:green)
        if showcounts
            print(io, histcounts[i])
        end
        println(io)
    end
    isempty(xlabel) || println(io, "\n", " "^max(plotwidth÷2 + 6 - length(xlabel)÷2, 0), xlabel)
    return nothing
end
