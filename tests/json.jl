using TimesDates, Dates, TSPLIB
import JSON
include("../utils/all.jl")
include("../algorithms/all.jl")
function jsonTabuSearch(
    cities::Array{Int}, # initial solution
    graph::Matrix, # distance matrix for TSP problem
    timeLimit::Int, # run time limit for tabu search
    tabuLen::Int, # length of tabu list
    longTimeLen::Int, # length of long time memory list
    upgrIterLimit::Int, # iteration limit since last improvement
    timeMargin::Float64, # shuffle until time elapsed < (1 - timeMargin) * TIME_LIMIT
    neighbourhood_search::Function,
    neighbourhood_search_destination::Function,
    iterStop::Bool, # true - stop tabu search after iterNumber iterations
    iterNumber::Int=0 # iteration limit for tabu ssearch
)
    iterations::Int = 0 # global iterations
    size::Int = cities |> length # problem size
    longTermMemory = [] # long time memory list
    bestCities::Array{Int} = cities # all time best solution
    bestDist::Float64 = destination(graph, cities) # all time best solution's distance
    tabuList::Array{Vector{Int}} = [[-1, -1] for _ ∈ 1:tabuLen] # tabu list
    TIME_LIMIT = Second(timeLimit) # given run time limit in seconds
    start = Dates.now()
    time_elapsed = Second(0)
    upgrade_iter::Int = 0
    UPGRADE_LIMIT::Int = upgrIterLimit
    globalCities::Array{Int} = copy(cities)
    currAttempt = Dict()
    #currAttempt[fld(time_elapsed.value, 1000)] = bestDist
    while (true)
        iterations += 1
        upgrade_iter += 1
        localCities::Array{Int} = globalCities
        localDist::Float64 = Inf
        move::Array{Int} = [-1, -1]
        for i = 1:size-1, j = i+1:size
            if time_elapsed > TIME_LIMIT || (iterStop && iterations > iterNumber)
                currAttempt[fld(time_elapsed.value, 1000)] = bestDist
                return currAttempt
            end
            #check iterations since last upgrade
            if upgrade_iter > UPGRADE_LIMIT
                #if upgrade_time_elapsed > UPGRADE_TIME
                upgrade_iter = 0
                UPGRADE_LIMIT += fld(iterations, 40)
                #println("limit : ", UPGRADE_LIMIT)
                #println("iterations : ", iterations)
                if isempty(longTermMemory)
                    # if time elapsed is more than f.e. 95% continue instead of shuffling
                    if time_elapsed < Second(floor(Int, TIME_LIMIT.value * (1 - timeMargin)))
                        shuffle!(globalCities)
                        #println("UPGRADING (shuffle)")
                    end
                else
                    kick = pop!(longTermMemory)
                    globalCities = kick[1]
                    tabuList = kick[2]
                    localCities = kick[1]
                    #println("KICKING")
                end
                break
            end

            # Copy localBest and invert
            currCities::Array{Int} = copy(localCities)
            neighbourhood_search(currCities, i, j)
            currDist::Float64 = neighbourhood_search_destination(graph, size, currCities, i, j, localDist)
            #Update time
            time_elapsed = Dates.now() - start
            #upgrade_time_elapsed = Dates.now() - upgrade_start
            #Check if on tabu list
            if [i, j] ∈ tabuList || [j, i] ∈ tabuList
                #aspiration
                if (currDist >= bestDist)
                    continue
                end
            end
            #Check if better than localBest
            if currDist < localDist
                localCities = currCities
                localDist = currDist
                move = [i, j]
            end
        end #end of for loops
        if fld(time_elapsed.value, 1000) % 2 == 0
            currAttempt[fld(time_elapsed.value, 1000)] = bestDist
        end
        #set globalBest as last localBest
        globalCities = localCities
        #update All best result if local/global is better
        if localDist < bestDist
            bestDist = localDist
            bestCities = localCities
            savedTabu = copy(tabuList)
            if length(longTermMemory) == longTimeLen && !isempty(longTermMemory)
                popfirst!(longTermMemory)
            end
            popfirst!(savedTabu)
            push!(savedTabu, move)
            if longTimeLen > 0
                push!(longTermMemory, [globalCities, savedTabu])
            end
            #println("New best distance: ", bestDist)
            upgrade_iter = 0
        end
        #add move to tabuList
        if move != [-1, -1]
            popfirst!(tabuList)
            push!(tabuList, move)
        end
        #println("Best distance: ", globalDistance, "Total Best: ", bestDist)
    end
    return currAttempt
end




function test_json1()
    results = Dict()
    problems = ["a280.tsp", "bier127.tsp", "pcb1173.tsp", "ch150.tsp", "vm1084.tsp", "u1060.tsp", "eil101.tsp", "eil51.tsp", "eil76.tsp", "fl417.tsp"]
    #problems = ["pcb1173.tsp",  "vm1084.tsp", "u1060.tsp"]

    title = "reverse"
    for i in problems
        results[i] = []
        lk = ReentrantLock()
        Threads.@threads for t in 1:Threads.nthreads()
            dict = structToDict(readTSP("../data/TSPLIB95/tsp/" * i))
            dimension = dict[:dimension]
            weights = dict[:weights]
            curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), floor(Int, log2(dimension)), dimension, 0.05, reverse_variant, reverse_variant_destination, false)
            lock(lk)
            push!(results[i], curr)
            unlock(lk)
            println("finished thread: ", t, " problem ", i, "title: ", title)
        end
    end


    isdir("../jsons") || mkdir("../jsons")
    open("../jsons/results-$title.json", "w") do io
        JSON.print(io, results)
    end
end

function test_json2()
    results = Dict()
    problems = ["a280.tsp", "bier127.tsp", "pcb1173.tsp", "ch150.tsp", "vm1084.tsp", "u1060.tsp", "eil101.tsp", "eil51.tsp", "eil76.tsp", "fl417.tsp"]
    #problems = ["pcb1173.tsp",  "vm1084.tsp", "u1060.tsp"]

    title = "long0"

    for i in problems
        results[i] = []
        lk = ReentrantLock()
        Threads.@threads for t in 1:Threads.nthreads()
            dict = structToDict(readTSP("../data/TSPLIB95/tsp/" * i))
            dimension = dict[:dimension]
            weights = dict[:weights]
            curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), 0, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
            lock(lk)
            push!(results[i], curr)
            unlock(lk)
            println("finished thread: ", t, " problem ", i, "title: ", title)
        end
    end


    isdir("../jsons") || mkdir("../jsons")
    open("../jsons/results-$title.json", "w") do io
        JSON.print(io, results)
    end
end

function test_json4()
    results = Dict()
    problems = ["a280.tsp", "bier127.tsp", "pcb1173.tsp", "ch150.tsp", "vm1084.tsp", "u1060.tsp", "eil101.tsp", "eil51.tsp", "eil76.tsp", "fl417.tsp"]
    #problems = ["pcb1173.tsp",  "vm1084.tsp", "u1060.tsp"]

    title = "rand_tabu"
    for i in problems
        results[i] = []
        lk = ReentrantLock()
        Threads.@threads for t in 1:Threads.nthreads()
            dict = structToDict(readTSP("../data/TSPLIB95/tsp/" * i))
            dimension = dict[:dimension]
            weights = dict[:weights]
            curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, rand((1:dimension)), floor(Int, log2(dimension)), dimension, 0.05, reverse_variant, reverse_variant_destination, false)
            lock(lk)
            push!(results[i], curr)
            unlock(lk)
            println("finished thread: ", t, " problem ", i, "title: ", title)
        end
    end


    isdir("../jsons") || mkdir("../jsons")
    open("../jsons/results-$title.json", "w") do io
        JSON.print(io, results)
    end
end


function test_json3()
    results = Dict()
    problems = ["a280.tsp", "bier127.tsp", "pcb1173.tsp", "ch150.tsp", "vm1084.tsp", "u1060.tsp", "eil101.tsp", "eil51.tsp", "eil76.tsp", "fl417.tsp"]
    #problems = ["pcb1173.tsp",  "vm1084.tsp", "u1060.tsp"]

    title = "swap"
    for i in problems
        results[i] = []
        lk = ReentrantLock()
        Threads.@threads for t in 1:Threads.nthreads()
            dict = structToDict(readTSP("../data/TSPLIB95/tsp/" * i))
            dimension = dict[:dimension]
            weights = dict[:weights]
            curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), floor(Int, log2(dimension)), dimension, 0.05, swap_variant, swap_variant_destination, false)
            lock(lk)
            push!(results[i], curr)
            unlock(lk)
            println("finished thread: ", t, " problem ", i, "title: ", title)
        end
    end


    isdir("../jsons") || mkdir("../jsons")
    open("../jsons/results-$title.json", "w") do io
        JSON.print(io, results)
    end
end


# @time test_json1()
# @time test_json2()
# @time test_json3()
@time test_json4()


# curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), floor(Int, log2(dimension)), dimension, 0.05, reverse_variant, reverse_variant_destination, false)
# curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), 0, dimension, 0.05, reverse_variant, reverse_variant_destination, false)
# curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, rand(dimension)), floor(Int, log2(dimension)), dimension, 0.05, reverse_variant, reverse_variant_destination, false)
# curr = jsonTabuSearch(kRandom(weights, dimension, 1000), weights, 100, floor(Int, sqrt(dimension)), floor(Int, log2(dimension)), dimension, 0.05, swap_variant, swap_variant_destination, false)
