using TimesDates
using TSPLIB

include("../utils/all.jl")
include("../algorithms/all.jl")

function tabuThreads(weights::Matrix, dimension)
    results = []
    bestDist = typemax(Float64)
    lk = ReentrantLock()
    Threads.@threads for i in 1:Threads.nthreads()
        # list = tabuSearch(kRandom(weights, dimension, 1000),weights,60,dimension)
        lock(lk)
        if (destination(weights, list) < bestDist)
            results = list
        end
        unlock(lk)
    end
    return results
end

function main()
    dict = structToDict(readTSPLIB(:a280))
    dimension = dict[:dimension]
    weights = dict[:weights]
    nodes = dict[:nodes]
    println(dict[:optimal])

    #list = tabuSearch(twooptacc(kRandom(weights,dimension,1000),weights,nodes, false), weights,300,floor(Int,sqrt(dimension)))
    #list = tabuThreads(weights, dimension)
    #list = tabuSearch(kRandom(weights, dimension, 1000), weights, 3000, floor(Int, sqrt(dimension)), 10, false, 4000)
    list = kRandom(weights, dimension, 1000)
    #list = twooptacc(list,weights,nodes,true);
    #tabuSearch(list,weights,500,7,10,dimension,0.02,false)
    #destination(weights, list) |> println

    list = tabuSearch(kRandom(weights, dimension, 1000), weights, 300, floor(Int, sqrt(dimension)), 0, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
    println(destination(weights, list))
    # destination(weights, list) |> println

    # sleep(3)
    # #list::Array{Int} = nearestforall(weights, dimension, nodes, false)
    # #destination(weights, list) |> println
    # list = tabuSearch(list, weights, 100, 10)
    # destination(weights, list) |> println
end

main()