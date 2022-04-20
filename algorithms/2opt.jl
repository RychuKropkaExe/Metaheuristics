include("../utils/all.jl")

function swap(tour::Array{Int}, i::Int, j::Int)::Array{Int}
    while i < j
        tour[i], tour[j] = tour[j], tour[i]
        i += 1
        j -= 1
    end
    return tour
end

function twoopt(cities::Array{Int}, graph::Matrix, nodes::Array{Int}, plot::Bool)::Array{Int}
    newTour = []
    size = cities |> length
    bestDist = destination(graph, cities)
    @label start_again
    for i = 1:size-1
        for j = i+1:size
            newTour = swap(copy(cities), i + 1, j)
            newDist = destination(graph, newTour)
            if newDist < bestDist
                cities = newTour
                bestDist = newDist
                if plot
                    myplot(cities, nodes, true)
                end
                @goto start_again
            end
        end
    end
    return cities
end

function twooptacc(cities::Array{Int}, graph::Matrix, nodes::Array{Int}, plot::Bool)::Array{Int}
    newTour = []
    size = cities |> length
    @label start_again
    for i = 1:size-1
        for j = i+1:size
            if (graph[cities[i], cities[i+1]] + graph[cities[j], cities[j == size ? 1 : j + 1]]) > (graph[cities[i], cities[j]] + graph[cities[i+1], cities[j == size ? 1 : j + 1]])
                newTour = swap(copy(cities), i + 1, j)
                cities = newTour
                if plot
                    myplot(cities, nodes, true)
                end
                @goto start_again
            end
        end
    end
    return cities
end