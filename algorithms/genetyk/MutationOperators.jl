include("Structs.jl")
include("../../utils/all.jl")
include("../nearest.jl")
dict = Dict{Any,Any}()

function initialize_dict(tsp_dict::Dict)
    global dict = tsp_dict
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

function IRGIBNNM_mutation_XD(child_path::Array{Int}, mutation_rate::Float64)
    len::Int = length(child_path)
    for _ in 1:2
        if rand(Float64) < mutation_rate
            rand_indx::Int = rand(1:len)
            rand_indx2::Int = rand(1:len)
            reverse!(child_path, rand_indx, rand_indx2)
            rand_point = floor(Int,rand(1:len))
            nearest_point = minDistance2(dict[:weights],rand_point,Array{Int,1}())
            nearest_point_index = 0
            for i in 1:len
                if child_path[i] == nearest_point[1]
                    nearest_point_index = i
                    break
                end
            end
            swap_point = nearest_point_index - rand(0:4)
            if swap_point < 1
                swap_point = len + swap_point
            end
            child_path[nearest_point_index], child_path[swap_point] = child_path[swap_point], child_path[nearest_point_index]
        end
    end         
end