include("../utils/all.jl")
using TimesDates
using Dates

function reverse_variant(cities::Array, i::Int, j::Int)
    a = view(cities, i:j)
    reverse!(a)
end
function swap_variant(cities::Array, i::Int, j::Int)
    cities[i], cities[j] = cities[j], cities[i]
end


function reverse_variant_destination(graph::Matrix, dimension::Int, cities::Array, i::Int, j::Int, curr_distance::Float64)
    tested_distance = curr_distance
    if i > j
        i, j = j, i
    end
    if curr_distance == Inf
        return destination(graph, cities)
    end
    firstDist::Float64 = 0.0
    newDist::Float64 = 0.0
    if i == j
        return curr_distance
    elseif i > 1 && j < dimension
        firstDist = graph[cities[i-1], cities[j]] + graph[cities[j+1], cities[i]]
        newDist = graph[cities[i-1], cities[i]] + graph[cities[j], cities[j+1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i == 1 && j < dimension
        firstDist = graph[cities[j], cities[dimension]] + graph[cities[i], cities[j+1]]
        newDist = graph[cities[i], cities[dimension]] + graph[cities[j], cities[j+1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i > 1 && j == dimension
        firstDist = graph[cities[i], cities[1]] + graph[cities[j], cities[i-1]]
        newDist = graph[cities[i], cities[i-1]] + graph[cities[j], cities[1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i == 1 && j == dimension
        return curr_distance
    end
end
function swap_variant_destination(graph::Matrix, dimension::Int, cities::Array, i::Int, j::Int, curr_distance::Float64)
    if curr_distance == Inf
        return destination(graph, cities)
    end
    tested_distance = curr_distance
    if i > j
        i, j = j, i
    end
    if i == j
        return curr_distance
    end
    i_next = i
    i_prev = i == 1 ? dimension : i - 1
    j_next = j == dimension ? 1 : j + 1
    j_prev = j - 1
    sum1 = graph[cities[j], cities[i_next]] + graph[cities[i], cities[j_prev]] + graph[cities[j], cities[i_prev]] + graph[cities[i], cities[j_next]]
    sum2 = graph[cities[i], cities[i_next]] + graph[cities[i], cities[i_prev]] + graph[cities[j], cities[j_next]] + graph[cities[j], cities[j_prev]]
    #println(curr_distance, ":",sum1, ":",sum2)
    if sum1 > sum2
        return destination(graph, cities)
    else
        return tested_distance
    end
    #return tested_distance - (sum1 - sum2)
end
#działający TS
#kryterium aspiracji
#liczenie i limit czasowy dzialania TS
#dlugość list tabu i dlugoterminowej jako argument
#metoda eksploracji - shuffle
#nie robimy ^ kicka jeśli upłynęło (1 - δ) * 100% limitu czasowego
function tabuSearch(
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
)::Array{Int}
    dimension = length(cities)
    iterations::Int = 0 # global iterationsśśś
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
    while (true)
        iterations += 1
        upgrade_iter += 1
        localCities::Array{Int} = globalCities
        localDist::Float64 = Inf
        move::Array{Int} = [-1, -1]
        for i = 1:size-1, j = i+1:size
            if time_elapsed > TIME_LIMIT || (iterStop && iterations > iterNumber)
                return bestCities
            end
            #check iterations since last upgrade
            if upgrade_iter > UPGRADE_LIMIT
                #if upgrade_time_elapsed > UPGRADE_TIME
                upgrade_iter = 0
                UPGRADE_LIMIT += iterations ÷ 40
#                println("limit : ", UPGRADE_LIMIT)
#                println("iterations : ", iterations)
                if isempty(longTermMemory)
                    # if time elapsed is more than f.e. 95% continue instead of shuffling
                    if time_elapsed < Second(floor(Int, TIME_LIMIT.value * (1 - timeMargin)))
                        shuffle!(globalCities)
#                        println("UPGRADING (shuffle)")
                    end
                else
                    kick = pop!(longTermMemory)
                    globalCities = kick[1]
                    tabuList = kick[2]
                    localCities = kick[1]
#                    println("KICKING")
                end
                break
            end

            # Copy localBest and invert
            currCities::Array{Int} = copy(localCities)
            neighbourhood_search(currCities, i, j)
            currDist::Float64 = neighbourhood_search_destination(graph, dimension, currCities, i, j, localDist)
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
#            println("New best distance: ", bestDist)
            #update time since last update
            upgrade_time_elapsed = Second(0)
            upgrade_start = Dates.now()
        end
        #add move to tabuList
        if move != [-1, -1]
            popfirst!(tabuList)
            push!(tabuList, move)
        end
        #println("Best distance: ", globalDistance, "Total Best: ", bestDist)
    end
    return bestCities
end
#TODO: stagnacja zamiana czasu na liczbe iteracji i zwiekszenie tego wraz ze wszystkimi iteracjami