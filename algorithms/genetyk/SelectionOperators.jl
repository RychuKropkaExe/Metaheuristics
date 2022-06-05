include("Structs.jl")
using StatsBase
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

function tournament_selection(population::Array{Chromosome}, n::Int)::Array{Tuple{Chromosome,Chromosome}}
    fitnesses = [(population[i].fitness,i) for i in 1:length(population)]
    rng = MersenneTwister()
    champions::Array{Chromosome} = []
    for i in 1:n
        slaves = sample(rng,fitnesses,3,replace = false)
        champion = slaves[1]
        if slaves[2][1] > champion[1]
            champion = slaves[2]
        end
        if slaves[3][1] > champion[1]
            champion = slaves[3]
        end
        push!(champions,population[champion[2]])
    end
    parents::Array{Tuple{Chromosome,Chromosome}} = [Tuple(sample(rng,champions,2)) for _ in 1:n]
    return parents
end