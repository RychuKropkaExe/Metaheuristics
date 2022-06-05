include("../../utils/all.jl")
include("../2opt.jl")
include("../krandom.jl")
include("all.jl")
include("Structs.jl")


function genetic(config::Config, f::GeneticFunctions)

    start::DateTime = Dates.now()
    population::Array{Chromosome} = f.initialize_population(config.tsp, config.population_size)
    min_value::Float64 = minimum(x -> x.distance, population)
    println("Initial distance: ", min_value)
    best::Float64 = min_value
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
        min_value = minimum(x -> x.distance, population)
        if min_value < best
            best = min_value
            println("Generation: ", generation, " Best: ", best, " Time: ", Dates.now() - start)
        end
        population = f.select_next_gen!(population, config.population_size)
        generation += 1
    end
    println("Generation: ", generation)
    return best
end

function select_top_next_gen!(population::Array{Chromosome}, n::Int)
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    return sorted[1:n]
end

function main()
    dict = structToDict(readTSPLIB(:a280))
    parameters::Config = Config(
        dict,
        Second(60),
        100,
        100,
        0.05
    )
    functions::GeneticFunctions = GeneticFunctions(
        k_means_clustering,
        tournament_selection,
        pm_crossover,
        reverse_mutation!,
        select_top_next_gen!
    )
    println(dict[:optimal])
    genetic(parameters, functions) |> println
end

main()
