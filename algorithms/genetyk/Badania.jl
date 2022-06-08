include("genetyk.jl")
using JSON



function badanie_GA()
    # problems = [
    #     "burma14", "gr17", "ulysses22", "fri26", "bays29", 
    #     "swiss42", "eil51", "st70", "eil76", "gr96", 
    #     "kroA100", "pr107", "bier127", "ch130", "gr137",
    #     "pr144", "kroA150", "u159", "si175", "kroB200"
    #     ]
    for (root, dirs, files) in walkdir("./Data")
        for file in files
            if occursin(".atsp",file)
                println("AAAAAAAAAAAAAA")
                instance = "./algorithms/genetyk/Data/"*file
                dict = structToDict(readTSP(instance))
                println(destination(dict[:weights],[i for i in 1:dict[:dimension]]))
                println(destination(dict[:weights],reverse([i for i in 1:dict[:dimension]])))
                exit(0)
            end
        end
    end
end

badanie_GA()
