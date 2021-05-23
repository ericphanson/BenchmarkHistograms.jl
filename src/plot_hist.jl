function simpleunicodehistogram(x::AbstractArray; nbins::Integer=10, plotwidth::Integer=30, showcounts::Bool=true, xlabel="", ylabel="")
    # Find bounds, round them nicely
    l, u = extrema(x)
    digitsneeded = ceil(Int, -log10(u-l))+1
    l = floor(l, digits=digitsneeded)
    u = ceil(u, digits=digitsneeded)

    # Fill histogram
    dx = (u - l) / nbins
    histcounts = fill(0, nbins)
    @inbounds for i ∈ 1:length(x)
        index = ceil(Int, (x[i] - l) / dx)
        if 1 <= index <= nbins
            histcounts[index] += 1
        end
    end
    binedges = range(l,u,length=nbins+1)

    # Print the histogram
    blocks = [" ","▏","▎","▍","▌","▋","▊","▉","█","█"]
    scale = plotwidth/maximum(histcounts)
    lowerlabels = string.(round.(binedges[1:end-1], digits=digitsneeded+ceil(Int,log10(nbins)-1)))
    upperlabels = string.(round.(binedges[2:end], digits=digitsneeded+ceil(Int,log10(nbins)-1)))
    longestlower = maximum(length.(lowerlabels))
    longestupper = maximum(length.(upperlabels))
    println(ylabel*"\n")
    for i=1:nbins
        nblocks = histcounts[i] * scale
        blockstring = repeat("█", floor(Int, nblocks)) * blocks[ceil(Int,(nblocks - floor(nblocks))*8)+1]
        println(" (" * lowerlabels[i] * " "^(longestlower - length(lowerlabels[i])) *
                " - " * upperlabels[i] * " "^(longestupper - length(upperlabels[i])) *
                    "]  " * blockstring * (showcounts ? " $(histcounts[i])" : ""))
    end
    println("\n" * " "^max(plotwidth÷2 + 6 - length(xlabel)÷2, 0) * xlabel)
end
