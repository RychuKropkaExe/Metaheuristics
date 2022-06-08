include("Structs.jl")
include("../../utils/all.jl")
include("../nearest.jl")


function select_tournament_next_gen(population::Array{Chromosome}, n::Int)::Array{Chromosome}
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    fitnesses = [(sorted[i].fitness,i) for i in 21:length(population)]
    rng = MersenneTwister()
    champions::Array{Chromosome} = []
    append!(champions,sorted[1:20])
    fitnesses = [(sorted[i].fitness,i) for i in 21:length(population)]
    for _ in 21:n
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
    return champions
end

function select_top_next_gen!(population::Array{Chromosome}, n::Int)
    sorted::Array{Chromosome} = sort(population, by=x -> x.distance)
    return sorted[1:n]
end

function replace_old_gen!(population::Array{Chromosome}, n::Int)
    return population[n+1:2*n]
end