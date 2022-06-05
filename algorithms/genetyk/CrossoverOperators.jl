include("Structs.jl")
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
    for i in 1:length(a)
        if i > cut_1 && i < cut_2
            continue
        elseif haskey(mapping_b,path_a[i])
            key = path_a[i]
            while haskey(mapping_b,mapping_b[key])
                key = mapping_b[key]
            end
            path_a[i] = mapping_b[key]
        end
    end
    for i in 1:length(a)
        if i > cut_1 && i < cut_2
            continue
        elseif haskey(mapping_a,path_b[i])
            key = path_b[i]
            while haskey(mapping_a,mapping_a[key])
                key = mapping_a[key]
            end
            path_b[i] = mapping_a[key]
        end
    end
    # for (k,v) in countmap(path_a)
    #     if v > 1
    #         println("DUPLICATE IN A!!!!!!!!!!!!!: ", cut_1, " ", cut_2, " ", findall(x->x==k, path_a), " ", path_a[findall(x->x==k, path_a)[1]])
    #         println(path_a)
    #         exit(0)
    #     end
    # end
    # for (k,v) in countmap(path_b)
    #     if v > 1
    #         println("DUPLICATE IN B!!!!!!!!!!!!!: ", k)
    #         println(path_b)
    #         exit(0)
    #     end
    # end
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