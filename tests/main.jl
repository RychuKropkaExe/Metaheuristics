using TimesDates
using TSPLIB

include("../utils/all.jl")
include("../algorithms/all.jl")

function xd()
    Threads.@threads for i in 1:Threads.nthreads()
    end
end

function main()
    dict = structToDict(readTSPLIB(:berlin52))
    dimension = dict[:dimension]
    weights = dict[:weights]
    nodes = dict[:nodes]
    println(dict[:optimal])

    #list = tabuSearch(twooptacc(kRandom(weights,dimension,1000),weights,nodes, false), weights,300,floor(Int,sqrt(dimension)))
    list = tabuSearch(kRandom(weights, dimension, 1000), weights, 300, floor(Int, sqrt(dimension)), 10, false, 4000, reverse_variant)
    println(destination(weights, list))
    # destination(weights, list) |> println
    # sleep(3)
    # #list::Array{Int} = nearestforall(weights, dimension, nodes, false)
    # #destination(weights, list) |> println
    # list = tabuSearch(list, weights, 100, 10)
    # destination(weights, list) |> println
end

main()