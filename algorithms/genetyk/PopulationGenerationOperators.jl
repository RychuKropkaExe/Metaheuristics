include("Structs.jl")
using Random
function random_population(tsp_dict::Dict, n::Int)::Array{Chromosome}
    dimension::Int = tsp_dict[:dimension]
    weights::Matrix{Float64} = tsp_dict[:weights]
    return [Chromosome(shuffle!(collect(1:dimension)), weights) for _ in 1:n]
end

function balanced_population(tsp_dict::Dict, n::Int)::Array{Chromosome}
    dimension::Int = tsp_dict[:dimension]
    weights::Matrix{Float64} = tsp_dict[:weights]
    return [Chromosome(k < 0.8 * n ? shuffle!(collect(1:dimension)) : twoopt(shuffle!(collect(1:dimension)), weights, tsp_dict[:nodes], false), weights) for k in 1:n]
end

function k_means_clustering(tsp_dict::Dict, n::Int)::Array{Chromosome}
    dimension::Int = tsp_dict[:dimension]
    weights::Matrix{Float64} = tsp_dict[:weights]
    array = shuffle(Array{Int,1}(1:dimension))
    size = floor(Int,sqrt(dimension))
    reminder = dimension % size
    groups::Array{Array{Int,1}} = []
    push!(groups,array[1:size+reminder])

    for i in (size+reminder)+1:size:dimension
        push!(groups,array[i:i+size-1])
    end

    for i in 1:length(groups)
        groups[i] = twooptacc(groups[i], weights,tsp_dict[:nodes],false)
    end

    population = Array{Chromosome,1}()

    for _ in 1:n
        sample = copy(groups)
        for i in 1:length(sample)
            cut_point = rand(1:length(sample[i])-1)
            disjoin_point_1 = sample[i][cut_point]
            cut_point_2 = cut_point + 1
            disjoin_point_2 = sample[i][cut_point_2]
            temp = []
            push!(temp,disjoin_point_1)
            for j in 1:length(sample[i])
                if sample[i][j] != disjoin_point_1 && sample[i][j] != disjoin_point_2
                    push!(temp,sample[i][j])
                end
            end
            push!(temp,disjoin_point_2)
            sample[i] = temp
        end
        result = Array{Int,1}()
        for group in shuffle(sample)
            append!(result,group)
        end
        push!(population,Chromosome(result,weights))
    end
    return population
end