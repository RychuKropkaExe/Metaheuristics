include("../algorithms/all.jl")
using TSPLIB
using Hyperopt
using Plots


function tuning()
    dict = structToDict(readTSPLIB(:d1291))
    dimension = dict[:dimension]
    weights = dict[:weights]
    nodes = dict[:nodes]
    println(dict[:optimal])
    base = kRandom(weights,dimension,1)
    arr = Array{Int,1}(1:dimension)
    arr2 = Array{Int,1}(20:floor(Int,log(dimension)):dimension)
    append!(arr,arr2)
    #b = Array{Int,1}(1:floor(log(dimension)))
    @time (ho = @hyperopt for i = 100, a = arr, b = 1
        cost = destination(weights,nearest3(weights,dimension,[a]))
    end)
    println(ho.minimizer, ":",ho.minimum, ":", ho.maximizer, ":", ho.maximum)
end