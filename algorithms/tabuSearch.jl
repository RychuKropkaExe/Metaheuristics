include("../utils/all.jl")
using TimesDates
using Dates

function tabuSearch(cities::Array{Int}, graph::Matrix, time::Int, len::Int)::Array{Int}
    size::Int = cities |> length

    bestCities::Array{Int} = cities
    bestDist::Float64 = destination(graph, cities)

    tabuList::Array{Vector{Int}} = [[-1, -1] for _ ∈ 1:len]

    TIME_LIMIT = Second(time)
    start = Dates.now()
    time_elapsed = Second(0)

    globalCities::Array{Int} = copy(cities)
    while (true)
        localCities::Array{Int} = globalCities
        localDist::Float64 = Inf
        move::Array{Int} = [-1, -1]
        for i = 1:size-1
            for j = i+1:size
                if (time_elapsed > TIME_LIMIT)
                    return cities
                end
                if [i, j] ∈ tabuList || [j, i] ∈ tabuList
                    continue
                end

                currCities::Array{Int} = copy(localCities)
                part = view(currCities, i:j)
                reverse!(part)

                currDist::Float64 = destination(graph, currCities)
                time_elapsed = Dates.now() - start

                if currDist < localDist
                    localCities = currCities
                    localDist = currDist
                    move = [i, j]
                end
            end
        end
        if localDist < bestDist
            bestDist = localDist
            bestCities = localCities
            println("New best distance: ", bestDist)
            #sleep(1)
        end
        globalCities = localCities
        if move != [-1, -1]
            popfirst!(tabuList)
            push!(tabuList, move)
        end
        #println("Best distance: ", globalDistance, "Total Best: ", bestDist)
    end
    return bestCities
end