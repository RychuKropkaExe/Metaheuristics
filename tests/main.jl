using TimesDates
using TSPLIB

include("../utils/all.jl")
include("../algorithms/all.jl")

function tabuThreads(weights::Matrix, dimension)
    results = []
    bestDist = typemax(Float64)
    lk = ReentrantLock()
    Threads.@threads for i in 1:Threads.nthreads()
        list = tabuSearch(kRandom(weights, dimension, 1000), weights, 120, fld(dimension, 2), 10, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
        currentDistance = destination(weights, list)
        lock(lk)
        if (currentDistance < bestDist)
            results = list
            bestDist = currentDistance
        end
        unlock(lk)
    end
    return results
end

function tabuThreadsCompare()
    problems = ["a280.tsp"] # "a280.tsp", "bier127.tsp", 
    println("\n\n\n")
    #println("tabuThreadsCompare, threads: ", Threads.nthreads())
    for i in problems
        dict = structToDict(readTSP("../data/TSPLIB95/tsp/" * i))
        weights = dict[:weights]
        dimension = dict[:dimension]
        println("problem: ", i)
        bestThreadDist = typemax(Float64)
        lk = ReentrantLock()
        Threads.@threads for i in 1:Threads.nthreads()
            list = tabuSearch(kRandom(weights, dimension, 1000), weights, 120, fld(dimension, 2), 10, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
            currentDistance = destination(weights, list)
            lock(lk)
            if (currentDistance < bestThreadDist)
                bestThreadDist = currentDistance
            end
            unlock(lk)
        end
        println("result for ", Threads.nthreads(), " parallel tabuSearch: ", bestThreadDist)
    end
end


function main()
    dict = structToDict(readTSPLIB(:a280))
    dimension = dict[:dimension]
    weights = dict[:weights]
    nodes = dict[:nodes]
    println(dict[:optimal])
    list = tabuSearch(kRandom(weights, dimension, 1000), weights, 120, fld(dimension, 2), 10, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
    dest = destination(weights, list)
    println("destination: ", dest)
end

tabuThreadsCompare()