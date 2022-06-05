include("Structs.jl")

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