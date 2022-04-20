include("../utils/all.jl")
using TimesDates
using Dates

function tabuSearch(cities::Array{Int}, graph::Matrix, time::Int, len::Int)::Array{Int}
    bestDist::Float64 = destination(graph, cities)

    tabuList::Array{Vector{Int}} = [[0, 0] for _ ∈ 1:len]


    size::Int = cities |> length

    TIME_LIMIT = Second(time)
    start = Dates.now()
    time_elapsed = Second(0)


    whileCities::Array{Int} = copy(cities)
    whileDistance::Float64 = bestDist
    while (true)
        newTour::Array{Int} = []
        currCities::Array{Int} = whileCities
        currBestDist::Float64 = Inf
        for i = 1:size-1
            for j = i+1:size
                if (time_elapsed > TIME_LIMIT)
                    return cities
                end
                if [i, j] ∈ tabuList
                    continue
                end                

                newTour = copy(currCities)
                part = view(newTour, i:j)
                reverse!(part)

                newDist::Float64 = destination(graph, newTour)
                time_elapsed = Dates.now() - start

                if newDist < currBestDist
                    if newDist < bestDist
                        bestDist = newDist
                        cities = newTour
                        println("New best distance: ", bestDist)
                        #sleep(1)
                    end
                    currCities = newTour
                    currBestDist = newDist

                    popfirst!(tabuList)
                    push!(tabuList, [i, j])
                end
            end
        end
        whileCities = currCities
        whileDistance = currBestDist
        #println("Best distance: ", whileDistance, "Total Best: ", bestDist)
    end
    return cities
end