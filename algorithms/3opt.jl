include("../utils/all.jl")

function three_opt_acc(graph::Matrix, road::Array{Int}, nodes::Array{Int}, plot::Bool)::Array{Int}
    best_road = copy(road)
    prev_best = copy(road)
    dimension = length(road)
    while (true)
        best_result = typemax(Int)
        for (a, b, c) in all_segments(dimension)
            diff, new_road = reverse_segment_if_better(prev_best, a, b, c, graph)
            if (diff < best_result)
                best_result = diff
                best_road = new_road
            end
        end
        if (best_result < 0)
            prev_best = best_road
            if plot
                myplot(prev_best, nodes, true)
            end
        else
            break
        end
    end
    return prev_best
end

function all_segments(dimension::Int)
    return ((i::Int, j::Int, k::Int)
            for i in 1:dimension
            for j in (i+2):dimension
            for k in (j+2):dimension)
end

function reverse_segment_if_better(road::Array{Int}, i::Int, j::Int, k::Int, graph::Matrix)
    A, B, C, D, E, F = road[i], road[i+1], road[j], road[j+1], road[k], road[k != length(road) ? k + 1 : 1]
    d0 = graph[A, B] + graph[C, D] + graph[E, F]
    d1 = graph[A, C] + graph[B, D] + graph[E, F]
    d2 = graph[A, C] + graph[B, E] + graph[D, F]
    d3 = graph[A, B] + graph[C, E] + graph[D, F]
    d4 = graph[A, D] + graph[E, B] + graph[C, F]
    d5 = graph[A, D] + graph[E, C] + graph[B, F]
    d6 = graph[A, E] + graph[D, B] + graph[C, F]
    d7 = graph[A, E] + graph[D, C] + graph[B, F]

    best = min(d0, d1, d2, d3, d4, d5, d6, d7)

    if (best == d0)
        return (0, road)
    elseif (best == d1)
        return (d1 - d0, reverse(road, i + 1, j))
    elseif (best == d2)
        return (d2 - d0, reverse(reverse(road, i + 1, j), j + 1, k))
    elseif (best == d3)
        return (d3 - d0, reverse(road, j + 1, k))
    elseif (best == d4)
        temp = road[1:i]
        append!(temp, road[j+1:k])
        append!(temp, road[i+1:j])
        if (k != length(road))
            append!(temp, road[k+1:end])
        end
        return (d4 - d0, temp)
    elseif (best == d5)
        temp = road[1:i]
        append!(temp, road[j+1:k])
        append!(temp, reverse(road[i+1:j]))
        if (k != length(road))
            append!(temp, road[k+1:end])
        end
        return (d5 - d0, temp)
    elseif (best == d6)
        temp = road[1:i]
        append!(temp, reverse(road[j+1:k]))
        append!(temp, road[i+1:j])
        if (k != length(road))
            append!(temp, road[k+1:end])
        end
        return (d6 - d0, temp)
    elseif (best == d7)
        return (d7 - d0, reverse(road, i + 1, k))
    end
end

