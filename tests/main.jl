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

    list::Array{Int} = twooptacc(kRandom(weights, dimension, 1000), weights, nodes, false)
    destination(weights, list) |> println
    sleep(3)
    #list::Array{Int} = nearestforall(weights, dimension, nodes, false)
    #destination(weights, list) |> println
    list = tabuSearch(list, weights, 100, 10)
    destination(weights, list) |> println
end

main()