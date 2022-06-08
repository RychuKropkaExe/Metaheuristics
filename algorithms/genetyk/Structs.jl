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
    max_stagnation::Int
end

struct GeneticFunctions
    initialize_population::Function
    parents_selection::Function
    crossover::Function
    mutation!::Function
    select_next_gen!::Function
end

mutable struct Island
    id::Int
    population::Array
    size::Int
    selection_operator::Function
    crossover_operator::Function
    mutation_operator::Function
    mutation_rate::Float64
    useless_generations::Int
    generation::Int
    island_best::Float64
    elite_deployment_rate::Int
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