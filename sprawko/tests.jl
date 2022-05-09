include("../algorithms/all.jl")
using TSPLIB
using Hyperopt
using Plots


function tuning()
    arrx = []
    arry = []
    for (root, dirs, files) in walkdir("./plikiTSP")
        for file in files
            path = "./plikiTSP/"*file
            dict = struct_to_dict(readTSP(path))
            graph = dict[:weights]
            dimension = dict[:dimension]
            dict = struct_to_dict(readTSP(file))
            base = kRandom(weights,dimension,1)
            arr = Array{Int,1}(1:floor(Int,log(dimension)))
            arr2 = Array{Int,1}(floor(Int,log(dimension)):floor(Int,log(dimension)):dimension)
            append!(arr,arr2)
            #b = Array{Int,1}(1:floor(log(dimension)))
            ho = @phyperopt for i = 100, a = arr, b = 1
                cost = destination(weights,kRandom(weights,dimension,a))
            end
            println(ho.minimizer, ":",ho.minimum, ":", ho.maximizer, ":", ho.maximum)
            push!(arrx,file)
            push!(arry, ho.minimizer[1])
            i+=1
        end
    end
    println(arrx)
    println(arry)
end