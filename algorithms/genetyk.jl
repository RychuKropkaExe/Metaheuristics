include("../utils/all.jl")
using TimesDates
using Dates
using TSPLIB
using Random
using StatsBase

struct Config
    tsp::Dict
    time::TimePeriod
    population_size::Int
    crossovers_count::Int
    mutation_rate::Float64
end

struct GeneticFunctions
    initialize_population::Function
    parents_selection::Function
    crossover::Function
    mutation!::Function
    select_next_gen!::Function
end


mutable struct Chromosome
    path::Array{Int}
    distance::Float64
    fitness::Float64
    age::Int
    function Chromosome(path::Array{Int}, distance::Float64)
        new(path, distance, 1 / (1 + distance), 0)
    end
    function Chromosome(path::Array{Int}, weights::Matrix{Float64})
        Chromosome(path, destination(weights, path))
    end
end

function genetic(config::Config, f::GeneticFunctions)

    start::DateTime = Dates.now()
    population::Array{Chromosome} = f.initialize_population(config.tsp, config.population_size)
    best::Float64 = minimum(x -> x.distance, population)
    generation::Int = 0
    while (Dates.now() - start < config.time)
        parents::Array{Tuple{Chromosome,Chromosome}} = f.parents_selection(population, config.crossovers_count)
        children_paths::Array{Array{Int}} = f.crossover(parents)
        for child_path::Array{Int} in children_paths
            f.mutation!(child_path, config.mutation_rate)
        end
        weights::Matrix{Float64} = config.tsp[:weights]
        children::Array{Chromosome} = []
        for child_path::Array{Int} in children_paths
            child::Chromosome = Chromosome(child_path, weights)
            push!(children, child)
        end
        for chromosome::Chromosome in population
            chromosome.age += 1
        end
        append!(population, children)
        best = min(best, minimum(x -> x.distance, population))
        f.select_next_gen!(population, config.population_size)
        generation += 1
    end
    println("Generation: ", generation)
    return best
end

function random_population(tsp_dict::Dict, n::Int)::Array{Chromosome}
    dimension::Int = tsp_dict[:dimension]
    weights::Matrix{Float64} = tsp_dict[:weights]
    return [Chromosome(shuffle!(collect(1:dimension)), weights) for _ in 1:n]
end

function random_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    return [Tuple(sample(population, 2)) for _ in 1:n]
end

function weighted_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    return [Tuple(sample(population, Weights((p -> p.fitness).(population)), 2)) for _ in 1:n]
end


function swap(a::Array{Int}, b::Array{Int})::Array{Array{Int}}
    len::Int = length(a)
    indx_a::Int = rand(2:len)
    indx_b::Int = rand(2:len)
    min_indx = min(indx_a, indx_b)
    max_indx = max(indx_a, indx_b)
    path_a::Array{Int} = []
    path_b::Array{Int} = []

    append!(path_a, @view a[1:min_indx-1])
    append!(path_a, @view b[min_indx:max_indx-1])
    append!(path_a, @view a[max_indx:len])

    append!(path_b, @view b[1:min_indx-1])
    append!(path_b, @view a[min_indx:max_indx-1])
    append!(path_b, @view b[max_indx:len])
    return [path_a, path_b]
end

function swap_crossover(parents::Array{Tuple{Chromosome,Chromosome}})::Array{Array{Int}}
    children_paths::Array{Array{Int}} = []
    for pair in parents
        parent_a::Chromosome = pair[1]
        parent_b::Chromosome = pair[2]
        append!(children_paths, swap(parent_a.path, parent_b.path))
    end
    return children_paths
end

function swap_mutation!(child_path::Array{Int}, mutation_rate::Float64)
    len::Float64 = length(child_path)
    for _ in 1:3
        if rand() < mutation_rate
            rand_indx::Int = rand(1:len)
            rand_indx2::Int = rand(1:len)
            child_path[rand_indx], child_path[rand_indx2] = child_path[rand_indx2], child_path[rand_indx]
        end
    end
end

function select_top_next_gen!(population::Array{Chromosome}, n::Int)
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    population = @view sorted[1:n]
end

function main()
    dict = structToDict(readTSPLIB(:bier127))
    parameters::Config = Config(
        dict,
        Second(10),
        100,
        10,
        0.3
    )
    functions::GeneticFunctions = GeneticFunctions(
        random_population,
        random_selection,
        swap_crossover,
        swap_mutation!,
        select_top_next_gen!
    )
    genetic(parameters, functions) |> println
end

main()
