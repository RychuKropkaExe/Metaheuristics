using Dates
include("../utils/all.jl")

function nearest(graph, startCity, dimension, nodes, plot)
    cities = Array(1:dimension)
    result::Array{Int} = []
    currentCity = splice!(cities, startCity)
    closestCity = first(cities)
    push!(result, currentCity)
    index = 1
    while cities |> length > 0

        dist = Inf

        for i = 1:length(cities)
            city = cities[i]
            tempDist = graph[currentCity, city]
            if tempDist < dist
                dist = tempDist
                closestCity = city
                index = i
                if plot
                    myplot(result, nodes, false)
                end
            end
        end

        currentCity = closestCity
        splice!(cities, index)
        push!(result, currentCity)
    end
    if plot
        myplot(result, nodes, true)
    end
    return result
end


function nearestforall(graph, dimension, nodes, plot)
    list = nearest(graph, 1, dimension, nodes, false)
    dest = destination(graph, list)
    for i = 2:dimension
        list2 = nearest(graph, i, dimension, nodes, false)
        tempdest = destination(graph, list2)
        if tempdest < dest
            list = list2
            dest = tempdest
            if plot
                myplot(list, nodes, true)
            end
        end
    end
    return list
end

function nearest3(weightsMatrix, dimension, currentPath)
    temp = length(currentPath)
    for i in temp:dimension-1
        nextTown = minDistance2(weightsMatrix, currentPath[i], currentPath)
        push!(currentPath, nextTown[1])
    end
    return currentPath
end

function nearestExtended(graph, startCity, dimension)
    TIME_LIMIT = Minute(5)
    start = Dates.now()
    time_elapsed = Minute(0)
    currPath = Array{Int,1}()
    push!(currPath, startCity)
    firstResult = nearest3(graph, dimension, [1])
    currBest = destination(graph, firstResult)
    pointer = 1
    while pointer != dimension && time_elapsed < TIME_LIMIT
        nearestTowns = minDistance2(graph, currPath[pointer], currPath)
        if length(nearestTowns) == 1
            push!(currPath, nearestTowns[1])
        else
            nextTown = nearestTowns[1]
            lk = ReentrantLock()
            Threads.@threads for i in 1:length(nearestTowns)
                tested = bestPathSearch(graph, dimension, currPath, nearestTowns[i])
                lock(lk)
                if tested < currBest
                    currBest = tested
                    nextTown = nearestTowns[i]
                end
                unlock(lk)
            end
            push!(currPath, nextTown)
        end
        pointer += 1
        time_elapsed = Dates.now() - start
    end
    return nearest3(graph, dimension, currPath)
end

function minDistance2(weightsMatrix::Matrix{Float64}, index::Int, visitedCities::Array{Int})
    min = Inf
    allIndexes = []
    for i in 1:length(weightsMatrix[:, index])
        if weightsMatrix[i, index] == min && !(i in visitedCities)
            push!(allIndexes, i)
        end
        if weightsMatrix[i, index] < min && weightsMatrix[i, index] > 0 && !(i in visitedCities)
            min = weightsMatrix[i, index]
            allIndexes = [i]
        end
    end
    return allIndexes
end

function bestPathSearch(graph, dimension, currPath, nearestTown)
    testedPath = copy(currPath)
    push!(testedPath, nearestTown)
    testedResult = nearest3(graph, dimension, testedPath)
    return destination(graph, testedResult)
end