function destination(graph::Matrix{Float64}, road::Array{Int})
    return sum(graph[road[i], road[i+1]] for i in 1:length(road)-1) + graph[road[length(road)], road[1]]
end