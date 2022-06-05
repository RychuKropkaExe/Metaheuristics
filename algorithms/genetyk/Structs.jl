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