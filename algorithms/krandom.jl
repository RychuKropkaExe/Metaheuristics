using Random
include("../utils/all.jl")

function kRandomPlot(weights::Matrix, dimension::Int, nodes::Array{Int}, k::Int, plot::Bool)
    bestDist = Inf
    bestRoad = []
    road = Array(1:dimension)
    for _ = 1:k
        road |> shuffle!
        if destination(weights, road) < bestDist
            bestDist = destination(weights, road)
            bestRoad = road
            if plot myplot(bestRoad, nodes, true) end
        end
    end
    return bestRoad
end

function kRandom(weights::Matrix, dimension::Int, k::Int)
    bestDist = Inf
    bestRoad = []
    lk = ReentrantLock()
    road = Array(1:dimension)
    t = ceil(Int,k/Threads.nthreads())
    Threads.@threads for i in 1:Threads.nthreads()
        tested = kRandomThreads(weights,dimension, t)
        lock(lk)
            if  tested[1] < bestDist
                bestDist = tested[1]
                bestRoad = tested[2]
            end
        unlock(lk)
    end
    return bestRoad
end

function kRandomThreads(weights::Matrix,dimension::Int, k::Int)
    bestDist = Inf
    bestRoad = []
    road = Array(1:dimension)
    for i in 1:k
        testedRoad = copy(road)
        testedRoad |> shuffle!
        tested = destination(weights, testedRoad)
        if  tested < bestDist
            bestDist = tested
            bestRoad = testedRoad
        end
    end
    return (bestDist, bestRoad)
end
