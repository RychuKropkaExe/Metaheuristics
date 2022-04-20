using TimesDates
using TSPLIB

include("../utils/all.jl")
include("../algorithms/all.jl")

function main()
    dict = structToDict(readTSPLIB(:a280))
    dimension = dict[:dimension]
    weights = dict[:weights]
    nodes = dict[:nodes]
    println(dict[:optimal])
    sleep(3)
    list::Array{Int} = twooptacc(kRandom(weights, dimension, 1000), weights, nodes, false)
    destination(weights, list) |> println
    list = tabuSearch(list, weights)
    destination(weights, list) |> println
end

main()