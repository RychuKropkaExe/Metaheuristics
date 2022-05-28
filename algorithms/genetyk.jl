include("../utils/all.jl")
using TimesDates
using Dates
using TSPLIB
using Random

struct Chromosome
    path::Array{Int}
    fitness::Float64
    age::Int
    function Chromosome(path::Array{Int}, fitness::Float64)
        new(path, fitness, 0)
    end
    function Chromosome(path::Array{Int}, weights::Matrix{Float64})
        Chromosome(path, destination(weights, path))
    end
end

function genetic(time_limit::DataType, initialize_population::Function, parents_selection::Function, crossover::Function, mutation::Function, select_next_gen!::Function)

    function update_best(best)
        return min(best, minimum(x -> x.fitness, population))
    end

    start::DateTime = Dates.now()

    population::Array{Chromosome} = initialize_population()
    best::Float64 = typemax(Float64)
    update_best(best)
    generation::Int = 0
    while (Dates.now() - start >= time_limit)
        parents::Array{Tuple{Chromosome,Chromosome}} = parents_selection(population)
        children::Array{Chromosome} = crossover(parents)
        for child::Chromosome in children
            mutation(child)
        end
        append!(population, children)
        best = update_best(best)
        select_next_gen!(population)
        generation += 1
    end
end


function main()
    dict = structToDict(readTSPLIB(:berlin52))
    weights = dict[:weights]
    dimension = dict[:dimension]

end
main()