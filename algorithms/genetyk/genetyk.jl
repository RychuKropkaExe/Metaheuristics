include("../../utils/all.jl")
include("../2opt.jl")
include("../krandom.jl")
include("all.jl")
include("Structs.jl")


function genetic(config::Config, f::GeneticFunctions)

    start::DateTime = Dates.now()
    population::Array{Chromosome} = f.initialize_population(config.tsp, config.population_size)
    min_value::Float64 = minimum(x -> x.distance, population)
    elite::Array{Chromosome} = []
    println("Initial distance: ", min_value)
    best::Float64 = min_value
    generation::Int = 0
    useless_generations = 0
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
            useless_generations = 0
            println("Generation: ", generation, " Best: ", best, " Time: ", Dates.now() - start)
        else
            useless_generations += 1
        end
        population = f.select_next_gen!(population, config.population_size)
        if length(elite) < config.population_size
            push!(elite,population[1])
        else
            pop!(elite)
            push!(elite,population[1])
        end
        if useless_generations == config.max_stagnation
            useless_generations = 0
            println("Stagnation prevention")
            population[floor(Int,config.population_size/2)+1:config.population_size] = shuffle(elite)[1:floor(Int,config.population_size/2)] 
            for _ in 1:floor(Int,config.population_size/10)
                shuffle!(population[rand(1:config.population_size)].path)
            end
        end
        generation += 1
    end
    println("Generation: ", generation)
    return best
end

function initialize_elite_island(config::Config,f::GeneticFunctions)
    return Island(1,
    f.initialize_population(config.tsp,config.population_size),
    config.population_size,
    tournament_selection,
    pm_crossover,
    IRGIBNNM_mutation_XD,
    0.05,
    0,
    0,
    Inf,
    config.max_stagnation*2)
end

function island_genetic(config::Config, f::GeneticFunctions)
    start::DateTime = Dates.now()
    challengers = [Array{Chromosome,1}() for _ in 1:Threads.nthreads()]
    selection_operators = [random_selection,roulette_wheel_selection,tournament_selection,weighted_selection]
    mutation_operators = [swap_mutation!,reverse_mutation!,IRGIBNNM_mutation_XD]
    crossover_operators = [swap_crossover,pm_crossover,order_crossover]
    islands::Array{Island} = []
    push!(islands, initialize_elite_island(config,f))
    for i in 2:Threads.nthreads()
        push!(islands,Island(i,
        f.initialize_population(config.tsp, config.population_size),
        config.population_size,
        selection_operators[rand(1:length(selection_operators))],
        crossover_operators[rand(1:length(crossover_operators))],
        mutation_operators[rand(1:length(mutation_operators))],
        rand(Float64)%0.05,
        0,
        0,
        Inf,
        config.max_stagnation))
    end
    min_values = [minimum(x->x.distance,islands[i].population) for i in 1:length(islands)]
    min_value::Float64 = minimum(min_values)
    println("Initial distance: ", min_value)
    best::Float64 = min_value
    generation::Int = 0
    lk = ReentrantLock()
    Threads.@threads for i in 1:Threads.nthreads()
        while (Dates.now() - start < config.time)
            islands[i].generation += 1
            parents::Array{Tuple{Chromosome,Chromosome}} = islands[i].selection_operator(islands[i].population,config.crossovers_count)
            children_paths::Array{Array{Int}} = islands[i].crossover_operator(parents)
            for child_path::Array{Int} in children_paths
                islands[i].mutation_operator(child_path,islands[i].mutation_rate)
            end
            weights::Matrix{Float64} = config.tsp[:weights]
            children::Array{Chromosome} = []
            for child_path::Array{Int} in children_paths
                child::Chromosome = Chromosome(child_path, weights)
                push!(children, child)
            end
            for chromosome::Chromosome in islands[i].population
                chromosome.age += 1
            end
            temp_population = copy(islands[i].population)
            append!(temp_population, children)
            min_value = minimum(x -> x.distance, temp_population)
            if min_value < islands[i].island_best
                islands[i].island_best = min_value
                islands[i].useless_generations = 0
            else
                islands[i].useless_generations += 1
            end 
            lock(lk)
                if min_value < best
                    best = min_value
                    println("Island: ",islands[i].id," Generation: ", islands[i].generation, " Best: ", best, " Time: ", Dates.now() - start)
                end
            unlock(lk)
            sorted::Array{Chromosome} = sort(temp_population, by=x -> x.distance)
            islands[i].population = sorted[1:islands[i].size]
            elite = sorted[1:floor(Int,config.population_size/2)]
            if (islands[i].generation - 1) % islands[i].elite_deployment_rate == 0 
                lock(lk)
                    challengers[i] = elite
                unlock(lk)
            end
            if islands[i].useless_generations >= config.max_stagnation
                islands[i].useless_generations = 0
                println("Migration on island: ", i)
                migrants::Array{Chromosome} = []
                choosen_island = rand(1:length(islands))
                while choosen_island == i
                    choosen_island = rand(1:length(islands))
                end
                lock(lk)
                    migrants = challengers[choosen_island]
                unlock(lk)
                islands[i].population[(1 + islands[i].size - floor(Int,islands[i].size/2)):islands[i].size] = migrants
                if i > 1
                    islands[i].selection_operator = selection_operators[rand(1:length(selection_operators))]
                    islands[i].crossover_operator = crossover_operators[rand(1:length(crossover_operators))]
                    islands[i].mutation_operator = mutation_operators[rand(1:length(mutation_operators))]
                    island[i].mutation_rate = rand(Float64)%0.05
                end
            end
        end
    end
    return best
end

function select_top_next_gen!(population::Array{Chromosome}, n::Int)
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    return sorted[1:n]
end

function replace_old_gen!(population::Array{Chromosome}, n::Int)
    return population[n+1:2*n]
end
function main()
    dict = structToDict(readTSPLIB(:berlin52))
    initialize_dict(dict)
    println(destination(dict[:weights],kRandom(dict[:weights],dict[:dimension],100000)))
    println(destination(dict[:weights],twooptacc(kRandom(dict[:weights],dict[:dimension],10000),dict[:weights],dict[:nodes],false)))
    parameters::Config = Config(
        dict,
        Second(60),
        280,
        140,
        0.05,
        500
    )
    functions::GeneticFunctions = GeneticFunctions(
        k_means_clustering,
        tournament_selection,
        pm_crossover,
        IRGIBNNM_mutation_XD!,
        select_top_next_gen!
    )
    IF_functions::GeneticFunctions = GeneticFunctions(
        random_population,
        roulette_wheel_selection,
        op_crossover,
        swap_mutation!,
        replace_old_gen!
    )
    println(dict[:optimal])
    genetic(parameters, functions) |> println
end

main()
