include("../algorithms/all.jl")
include("../utils/all.jl")
using TSPLIB
using Hyperopt
using Plots

function tuning()
    arrx = []
    arry = []
    arry2 = []
    for (root, dirs, files) in walkdir("./sprawko/plikiTSP")
        for file in files
            path = "./sprawko/plikiTSP/"*file
            dict = structToDict(readTSP(path))
            graph = dict[:weights]
            dimension = dict[:dimension]
            base = kRandom(graph,dimension,1)
            arr = Array{Int,1}(1:floor(Int,sqrt(dimension)))
            arr2 = Array{Int,1}(1:floor(Int,sqrt(dimension)):dimension)
            append!(arr,arr2)
            barr = Array{Int,1}(1:floor(Int,sqrt(dimension)))
            ho = @phyperopt for i = floor(Int,sqrt(dimension)), a = arr, b = barr
                cost = destination(graph,tabuSearch(base,graph,30,a,b,false,1,reverse_variant,reverse_variant_destination))
            end
            #println(ho.minimizer, ":",ho.minimum, ":", ho.maximizer, ":", ho.maximum)
            push!(arrx,file)
            push!(arry2,ho.minimum)
            push!(arry, ho.minimizer)
            i+=1
        end
    end
    println(arrx)
    println(arry)
end