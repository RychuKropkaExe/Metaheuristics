include("genetyk.jl")
using JSON

function test_genetic(config::Config, f::GeneticFunctions)
    history = []
    start::DateTime = Dates.now()
    population::Array{Chromosome} = f.initialize_population(config.tsp, config.population_size)
    min_value::Float64 = minimum(x -> x.distance, population)
    elite::Array{Chromosome} = []
    #println("Initial distance: ", min_value)
    best::Float64 = min_value
    push!(history,[best,Second(0)])
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
            push!(history,[best,Dates.now() - start])
            useless_generations = 0
            #println("Generation: ", generation, " Best: ", best, " Time: ", Dates.now() - start)
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
        if useless_generations >= config.max_stagnation
            useless_generations = 0
            #println("Stagnation prevention")
            population[ceil(Int,config.population_size/2)+1:config.population_size] = shuffle(elite)[1:floor(Int,config.population_size/2)] 
            for _ in 1:floor(Int,config.population_size/10)
                shuffle!(population[rand(1:config.population_size)].path)
            end
        end
        generation += 1
    end
    push!(history,[best,config.time])
    return history
end
function config_to_string(config::Config)
    conf = ["$(config.time)","$(config.population_size)","$(config.crossovers_count)","$(config.mutation_rate)","$(config.max_stagnation)"]
    return conf
end

function functions_to_string(func::GeneticFunctions)
    gf = ["$(func.initialize_population)", "$(func.parents_selection)","$(func.crossover)","$(func.mutation!)","$(func.select_next_gen!)"]
    return gf
end

function badanie_GA(problem::String)
    initial_population_opeators = [k_means_clustering,random_population]
    ips_length = length(initial_population_opeators)
    selection_operators = [random_selection,roulette_wheel_selection,tournament_selection,weighted_selection]
    so_length = length(selection_operators)
    mutation_operators = [swap_mutation!,reverse_mutation!,IRGIBNNM_mutation_XD]
    mo_length = length(mutation_operators)
    crossover_operators = [swap_crossover,pm_crossover,order_crossover,op_crossover]
    co_length = length(crossover_operators)
    next_gen_operators = [select_top_next_gen!,select_tournament_next_gen]
    ngo_length = length(next_gen_operators)
    results = Dict{String,Array}()
    results[problem] = []
    rng = MersenneTwister()
    lk = ReentrantLock()
    println("instancja: $problem")
    dict = structToDict(readTSP("./algorithms/genetyk/Data/"*problem))
    initialize_dict(dict)
    dimension = dict[:dimension]
    for i in 1:1
        println("Iteration: $i t: $(Threads.threadid())")
        sample = []
        parameters::Config = Config(
            dict,
            Second(60),
            100,
            50,
            0.05,
            1000
        )
        IF_functions::GeneticFunctions = GeneticFunctions(
        random_population,
        roulette_wheel_selection,
        op_crossover,
        swap_mutation!,
        select_tournament_next_gen
    )
        #println(config_to_string(parameters), " ", functions_to_string(functions), " $i")
        push!(sample,config_to_string(parameters))
        push!(sample,functions_to_string(IF_functions))
        push!(sample, test_genetic(parameters,IF_functions))
        push!(results[problem],sample)
        println("ITERATION $i DONE")
    end
    return results
end


#problems = ["kroB100.tsp","kroA100.tsp","gr17.tsp","eil101.tsp","eil51.tsp","a280.tsp","lin105.tsp",
 #           "ry48p.atsp","p43.atsp","kro124p.atsp","ftv64.atsp","ftv44.atsp","ftv35.atsp","ftv33.atsp","br17.atsp"]
problems =["ftv64.atsp","ftv44.atsp","ftv35.atsp","ftv33.atsp","br17.atsp"]
lk = ReentrantLock()
for problem in problems
    println("instancja: $problem")
    dict = structToDict(readTSP("./algorithms/genetyk/Data/"*problem))
    initialize_dict(dict)
    parameters::Config = Config(
            dict,
            Second(120),
            100,
            50,
            0.05,
            1000
    )
    functions::GeneticFunctions = GeneticFunctions(
        random_population,
        tournament_selection,
        pm_crossover,
        reverse_mutation!,
        select_tournament_next_gen
    )
    result = island_genetic(parameters,functions)
    lock(lk)
        open("./algorithms/genetyk/jsonsMulti/MultiThreadResults"*problem, "w") do io
            JSON.print(io,result)
        end
    unlock(lk)
end
