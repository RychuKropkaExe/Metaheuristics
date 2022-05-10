include("../algorithms/all.jl")
include("../utils/all.jl")
using TSPLIB
using Hyperopt
using Plots

function tuning()
    arrx = []
    arry = []
    for (root, dirs, files) in walkdir("./sprawko/plikiTSP")
        for file in files
            path = "./sprawko/plikiTSP/"*file
            dict = structToDict(readTSP(path))
            graph = dict[:weights]
            dimension = dict[:dimension]
            base = kRandom(graph,dimension,1)
            arr = Array{Int,1}(1:floor(Int,log(dimension)))
            arr2::Array{Int,1} = [floor(Int,sqrt(dimension)),floor(Int,dimension/2),dimension, 2*dimension]
            append!(arr,arr2)
            barr = Array{Int,1}(1:floor(log(dimension)))
            ho = @phyperopt for i = 100, a = arr, b = barr
                cost = destination(graph,tabuSearch(base,graph,30,a,b,false,1,reverse_variant,reverse_variant_destination))
            end
            println(ho.minimizer, ":",ho.minimum, ":", ho.maximizer, ":", ho.maximum)
            push!(arrx,file)
            push!(arry, ho.minimizer[1])
            i+=1
            println(arrx)
            println(arry)
            exit(0)
        end
    end
    println(arrx)
    println(arry)
end