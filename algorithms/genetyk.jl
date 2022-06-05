include("../utils/all.jl")
include("2opt.jl")
include("krandom.jl")
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
    min_value::Float64 = minimum(x -> x.distance, population)
    best::Float64 = min_value
    generation::Int = 0
    while (Dates.now() - start < config.time)
        println(length(population))
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

function random_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    return [Tuple(sample(population, 2)) for _ in 1:n]
end

function weighted_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    return [Tuple(sample(population, Weights((p -> p.fitness).(population)), 2)) for _ in 1:n]
end

function roulette_wheel_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    sum = 0
    sorted_population = sort(population, by=x -> x.fitness)
    for i in 1:length(population)
        sum += population[i].fitness
    end
    order = floor(sum) + 1
    parents::Array{Tuple{Chromosome,Chromosome}} = []
    for i in 1:n
        count = 0
        pair::Array{Chromosome} = []
        while count != 2
            partial_sum = 0
            limit = rand(Float64)*order
            for j in 1:length(sorted_population)
                partial_sum += sorted_population[j].fitness
                if partial_sum > limit
                    if count == 1 && pair[1] == sorted_population[j]
                        continue
                    else
                        push!(pair, sorted_population[j])
                        count += 1
                        partial_sum = 0
                        break
                    end
                end
            end
        end
        push!(parents,(pair[1],pair[2]))
    end
    return parents
end     

function swap(a::Array{Int}, b::Array{Int})::Array{Array{Int}}
    len::Int = length(a)
    indx_a::Int = rand(2:len)
    indx_b::Int = rand(2:len)
    min_indx = min(indx_a, indx_b)
    max_indx = max(indx_a, indx_b)

    path_a::Array{Int} = []
    set_b::Set{Int} = Set(b[min_indx:max_indx])
    cnt_a::Int = 0
    i::Int = 1
    while true
        if in(a[i], set_b)
            i += 1
        else
            push!(path_a, a[i])
            cnt_a += 1
            i += 1
        end

        if cnt_a == min_indx - 1
            append!(path_a, b[min_indx:max_indx])
            cnt_a += max_indx - min_indx + 1
        end

        if i > len
            break
        end
    end

    set_a::Set{Int} = Set(a[min_indx:max_indx])
    path_b::Array{Int} = []
    cnt_b::Int = 0
    j::Int = 1
    while true
        if in(b[j], set_a)
            j += 1
        else
            push!(path_b, b[j])
            cnt_b += 1
            j += 1
        end

        if cnt_b == min_indx - 1
            append!(path_b, a[min_indx:max_indx])
            cnt_b += max_indx - min_indx + 1
        end

        if j > len
            break
        end
    end
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

function partial_mapping(a::Array{Int}, b::Array{Int})::Array{Array{Int}}
    path_a::Array{Int} = copy(a)
    path_a.=0
    path_b::Array{Int} = copy(b)
    path_b.=0

    mapping_a = Dict{Int,Int}()
    mapping_b = Dict{Int,Int}()

    cut_1 = rand(3:length(a)-3)
    cut_2 = cut_1
    while cut_2 == cut_1
        cut_2 = rand(cut_1+1:length(a))
    end

    path_a[1:cut_1] = a[1:cut_1]
    path_a[cut_2:length(a)] = a[cut_2:length(a)]
    path_a[cut_1+1:cut_2-1] = b[cut_1+1:cut_2-1]
    path_b[1:cut_1] = b[1:cut_1]
    path_b[cut_2:length(a)] = b[cut_2:length(a)]
    path_b[cut_1+1:cut_2-1] = a[cut_1+1:cut_2-1]

    for i in cut_1+1:cut_2-1
        mapping_a[a[i]] = b[i]
        mapping_b[b[i]] = a[i]
    end

    #iskey
    for i in 1:length(a)
        if i > cut_1 && i < cut_2
            continue
        elseif haskey(mapping_b,path_a[i])
            if  haskey(mapping_b, mapping_b[path_a[i]])
                path_a[i] = mapping_b[mapping_b[path_a[i]]]
            else
                path_a[i] = mapping_b[path_a[i]]
            end
        end
    end
    for i in 1:length(a)
        if i > cut_1 && i < cut_2
            continue
        elseif haskey(mapping_a,path_b[i])
            if  haskey(mapping_a, mapping_a[path_b[i]])
                path_b[i] = mapping_a[mapping_a[path_b[i]]]
            else
                path_b[i] = mapping_a[path_b[i]]
            end
        end
    end
    return [path_a, path_b]
end

function pm_crossover(parents::Array{Tuple{Chromosome,Chromosome}})::Array{Array{Int}}
    children_paths::Array{Array{Int}} = []
    for pair in parents
        parent_a::Chromosome = pair[1]
        parent_b::Chromosome = pair[2]
        append!(children_paths, partial_mapping(parent_a.path, parent_b.path))
    end
    return children_paths
end

function order(a::Array{Int}, b::Array{Int})::Array{Array{Int}}
    path_a::Array{Int} = copy(a)
    path_a.=0
    path_b::Array{Int} = copy(b)
    path_b.=0

    mapping_a = Dict{Int,Int}()
    mapping_b = Dict{Int,Int}()

    cut_1 = rand(3:length(a)-3)
    cut_2 = cut_1

    while cut_2 == cut_1
        cut_2 = rand(cut_1+1:length(a))
    end

    path_a[cut_1+1:cut_2-1] = a[cut_1+1:cut_2-1]
    path_b[cut_1+1:cut_2-1] = b[cut_1+1:cut_2-1]

    for i in cut_1+1:cut_2-1
        mapping_a[a[i]] = b[i]
        mapping_b[b[i]] = a[i]
    end

    pointer_1 = cut_2
    pointer_2 = cut_2
    
    counter = 0
    limit = length(a) - (cut_2 - cut_1) + 1
    while true
        if pointer_2 > length(a)
            pointer_2 = 1
        end
        if pointer_1 > length(a)
            pointer_1 = 1
        end
        if haskey(mapping_a,b[pointer_2])
            pointer_2+=1
        else
            path_a[pointer_1] = b[pointer_2]
            pointer_1 += 1
            pointer_2 += 1
            counter += 1
        end
        if counter == limit
            break
        end
    end

    pointer_1 = cut_2
    pointer_2 = cut_2
    counter = 0
    while true
        if pointer_2 > length(a)
            pointer_2 = 1
        end
        if pointer_1 > length(a)
            pointer_1 = 1
        end
        if haskey(mapping_b,a[pointer_2])
            pointer_2+=1
        else
            path_b[pointer_1] = a[pointer_2]
            pointer_1 += 1
            pointer_2 += 1
            counter += 1
        end
        if counter == limit
            break
        end
    end
    return [path_a, path_b]
end

function order_crossover(parents::Array{Tuple{Chromosome,Chromosome}})::Array{Array{Int}}
    children_paths::Array{Array{Int}} = []
    for pair in parents
        parent_a::Chromosome = pair[1]
        parent_b::Chromosome = pair[2]
        append!(children_paths, order(parent_a.path, parent_b.path))
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

function reverse_mutation!(child_path::Array{Int}, mutation_rate::Float64)
    len::Float64 = length(child_path)
    for _ in 1:2
        if rand() < mutation_rate
            rand_indx::Int = rand(1:len)
            rand_indx2::Int = rand(1:len)
            reverse!(child_path, rand_indx, rand_indx2)
        end
    end
end

function select_top_next_gen!(population::Array{Chromosome}, n::Int)
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    #population = @view sorted[1:n]
    return sorted[1:n]
end

function main()
    dict = structToDict(readTSPLIB(:berlin52))
    #println(destination(dict[:weights],twooptacc(kRandom(dictA[:weights],dict[:dimension],10),dict[:weights],dict[:nodes],false)))
    println("k-random: ", destination(dict[:weights],kRandom(dict[:weights],dict[:dimension],100000)))
    parameters::Config = Config(
        dict,
        Second(600),
        52,
        52,
        0.1
    )
    functions::GeneticFunctions = GeneticFunctions(
        random_population,
        roulette_wheel_selection,
        swap_crossover,
        swap_mutation!,
        select_top_next_gen!
    )
    println(dict[:optimal])
    genetic(parameters, functions) |> println
end

main()
