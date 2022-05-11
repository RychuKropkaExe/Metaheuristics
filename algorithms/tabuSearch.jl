include("../utils/all.jl")
using TimesDates
using Dates
function reverse_variant(cities::Array, i::Int, j::Int)
    a = view(cities,i:j)
    reverse!(a)
end
function swap_variant(cities::Array,i::Int,j::Int)
    cities[i], cities[j] = cities[j], cities[i]
end


function reverse_variant_destination(graph::Matrix, dimension::Int, cities::Array, i::Int, j::Int, curr_distance::Float64)
    tested_distance = curr_distance
    if i > j
        i, j = j, i
    end
    if curr_distance == Inf
        return destination(graph,cities)
    end
    firstDist::Float64 = 0.0
    newDist::Float64 = 0.0
    if i == j
        return curr_distance
    elseif i > 1 && j < dimension
        firstDist = graph[cities[i-1],cities[j]] + graph[cities[j+1],cities[i]]
        newDist = graph[cities[i-1],cities[i]] + graph[cities[j],cities[j+1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i == 1 && j < dimension
        firstDist = graph[cities[j],cities[dimension]] + graph[cities[i],cities[j+1]]
        newDist = graph[cities[i],cities[dimension]] + graph[cities[j],cities[j+1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i > 1 && j == dimension
        firstDist = graph[cities[i],cities[1]] + graph[cities[j],cities[i-1]]
        newDist = graph[cities[i],cities[i-1]] + graph[cities[j],cities[1]]
        tested_distance -= firstDist
        tested_distance += newDist
        return tested_distance
    elseif i == 1 && j == dimension
        return curr_distance
    end  
end
function swap_variant_destination(graph::Matrix, dimension::Int, cities::Array, i::Int, j::Int, curr_distance::Float64)
    if curr_distance == Inf
        return destination(graph,cities)
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
            return destination(graph,cities)
    else
            return tested_distance
    end
    #return tested_distance - (sum1 - sum2)
end
function tabuSearch(
    cities::Array{Int},
    graph::Matrix,
    time::Int,
    tabuLen::Int,
    longTimeLen::Int,
    iterStop::Bool,
    iterNumber::Int,
    neighbourhood_search::Function,
    neighbourhood_search_destination::Function
)::Array{Int}
    dimension = length(cities)
    iterations::Int = 0
    size::Int = cities |> length
    longTermMemory = []
    bestCities::Array{Int} = cities
    bestDist::Float64 = destination(graph, cities)
    tabuList::Array{Vector{Int}} = [[-1, -1] for _ ∈ 1:tabuLen]
    TIME_LIMIT = Second(time)
    start = Dates.now()
    time_elapsed = Second(0)
    UPGRADE_TIME = Second(20)
    upgrade_start = Dates.now()
    upgrade_time_elapsed = Second(0)
    globalCities::Array{Int} = copy(cities)
    while (true)
        iterations += 1
        localCities::Array{Int} = globalCities
        localDist::Float64 = Inf
        move::Array{Int} = [-1, -1]
        for i = 1:size-1, j = i+1:size
            if time_elapsed > TIME_LIMIT || (iterStop && iterations > iterNumber)
                return bestCities
            end

            if upgrade_time_elapsed > UPGRADE_TIME
                upgrade_time_elapsed = Second(0)
                upgrade_start = Dates.now()
                if isempty(longTermMemory)
                    shuffle!(globalCities)
                    println("UPGRADING")
                else
                    #kick = rand(1:length(longTermMemory))
                    kick = pop!(longTermMemory)
                    globalCities = kick[1]
                    tabuList = kick[2]
                    localCities = kick[1]
                    println(tabuList)
                    println("KICKING")
                    sleep(5)
                end
                break
            end

            if [i, j] ∈ tabuList || [j, i] ∈ tabuList
                if (currDist >= bestDist)
                    continue
                end
            end

            currCities::Array{Int} = copy(localCities)
            neighbourhood_search(currCities, i, j)
            currDist::Float64 = neighbourhood_search_destination(graph,dimension,currCities,i,j,localDist)

            time_elapsed = Dates.now() - start
            upgrade_time_elapsed = Dates.now() - upgrade_start
            if currDist < localDist
                localCities = currCities
                localDist = currDist
                move = [i, j]
            end
        end
        globalCities = localCities
        if localDist < bestDist
            bestDist = localDist
            bestCities = localCities
            savedTabu = copy(tabuList)
            if length(longTermMemory) == longTimeLen
                popfirst!(longTermMemory)
            end
            popfirst!(savedTabu)
            push!(savedTabu, move)
            push!(longTermMemory, [globalCities, savedTabu])
            println("New best distance: ", bestDist)
            upgrade_time_elapsed = Second(0)
            upgrade_start = Dates.now()
        end
        if move != [-1, -1]
            popfirst!(tabuList)
            push!(tabuList, move)
        end
        #println("Best distance: ", globalDistance, "Total Best: ", bestDist)
    end
    return bestCities
end