include("Structs.jl")

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