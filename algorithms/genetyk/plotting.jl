include("plots.jl")
using JSON




function best_parametres()
end

function parametry_odniesienia()
    odniesienie = Dict{String,Array}()
    for (root, dirs, files) in walkdir("./algorithms/genetyk/jsonsOdniesienia")
        for file in files
            f = open("./algorithms/genetyk/jsonsOdniesienia/"*file)
            name = file[28:length(file)]
            df = JSON.parse(read(f,String))
            #println(df[name][1][3][1])
            dc = Dict{String,Array}()
            dc[name] = []
            for i in 1:length(df[name][1][3])
                push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
            end
            times = []
            values = []
            for i in 1:length(dc[name])
                push!(times,dc[name][i][2])
                push!(values,dc[name][i][1])
            end
            #dc[name] = [times,values]
            odniesienie[name] = [sort(times),reverse(sort(values))]
            #println(dc)
            #exit(0)
        end
    end
    return odniesienie
end

function separator()
    problems = ["kroB100.tsp","kroA100.tsp","gr17.tsp","eil101.tsp","eil51.tsp","a280.tsp","lin105.tsp", "berlin52.tsp",
              "ry48p.atsp","p43.atsp","kro124p.atsp","ftv64.atsp","ftv44.atsp","ftv35.atsp","ftv33.atsp","br17.atsp"]
    populacja = Dict{String,Dict}()
    populacja["k_means"] = Dict{String,Array}()
    selekcja = Dict{String,Dict}()
    crossover = Dict{String,Dict}()
    mutacja = Dict{String,Dict}()
    next_gen = Dict{String,Dict}()
    for (root, dirs, files) in walkdir("./algorithms/genetyk/jsonswpływ")
        for file in files 
            f = open("./algorithms/genetyk/jsonswpływ/"*file)
            df = JSON.parse(read(f,String))
            type = file[17:length(file)]
            name = " "
            if contains(type,"Populacji")
                name = file[26:length(file)]
                dc = Dict{String,Array}()
                dc[name] = []
                populacja["k_means"][name] = []
                for i in 1:length(df[name][1][3])
                    push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
                end
                times = []
                values = []
                for i in 1:length(dc[name])
                    push!(times,dc[name][i][2])
                    push!(values,dc[name][i][1])
                end
                populacja["k_means"][name] = [sort(times),reverse(sort(values))]
            end
            if contains(type,"selekcji")
                for problem in problems
                    if contains(type,problem)
                        name = problem
                        type = file[25:(length(file)-length(name))]
                        break
                    end
                end
                dc = Dict{String,Array}()
                dc[name] = []
                if !haskey(selekcja,type)
                    selekcja[type] = Dict{String,Array}()
                end
                selekcja[type][name] = []
                for i in 1:length(df[name][1][3])
                    push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
                end
                times = []
                values = []
                for i in 1:length(dc[name])
                    push!(times,dc[name][i][2])
                    push!(values,dc[name][i][1])
                end
                selekcja[type][name] = [sort(times),reverse(sort(values))]
            end
            if contains(type,"NextGen")
                for problem in problems
                    if contains(type,problem)
                        name = problem
                        type = file[24:(length(file)-length(name))]
                        break
                    end
                end
                dc = Dict{String,Array}()
                dc[name] = []
                if !haskey(next_gen,type)
                    next_gen[type] = Dict{String,Array}()
                end
                next_gen[type][name] = []
                for i in 1:length(df[name][1][3])
                    push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
                end
                times = []
                values = []
                for i in 1:length(dc[name])
                    push!(times,dc[name][i][2])
                    push!(values,dc[name][i][1])
                end
                next_gen[type][name] = [sort(times),reverse(sort(values))]
            end
            if contains(file,"Krzyżowania")
                for problem in problems
                    if contains(file,problem)
                        name = problem
                        type = file[29:(length(file)-length(name) + 1)]
                        break
                    end
                end
                dc = Dict{String,Array}()
                dc[name] = []
                if !haskey(crossover,type)
                    crossover[type] = Dict{String,Array}()
                end
                crossover[type][name] = []
                for i in 1:length(df[name][1][3])
                    push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
                end
                times = []
                values = []
                for i in 1:length(dc[name])
                    push!(times,dc[name][i][2])
                    push!(values,dc[name][i][1])
                end
                crossover[type][name] = [sort(times),reverse(sort(values))]
            end
            if contains(file,"Mutowania")
                for problem in problems
                    if contains(file,problem)
                        name = problem
                        type = file[26:(length(file)-length(name))]
                        break
                    end
                end
                dc = Dict{String,Array}()
                dc[name] = []
                if !haskey(mutacja,type)
                    mutacja[type] = Dict{String,Array}()
                end
                mutacja[type][name] = []
                for i in 1:length(df[name][1][3])
                    push!(dc[name],[df[name][1][3][i][1],df[name][1][3][i][2]["value"]])
                end
                times = []
                values = []
                for i in 1:length(dc[name])
                    push!(times,dc[name][i][2])
                    push!(values,dc[name][i][1])
                end
                mutacja[type][name] = [sort(times),reverse(sort(values))]
            end
        end
    end
    println(populacja)
    return [populacja,selekcja,crossover,mutacja, next_gen]
end

function wykresy()
    dicts = separator()
    populacja = dicts[1]
    selekcja = dicts[2]
    crossover = dicts[3]
    odniesienie = parametry_odniesienia()

end
function statistical_tests()
end

#parameters_impact()
separator()
