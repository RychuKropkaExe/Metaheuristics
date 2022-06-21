include("plots.jl")
using JSON
using HypothesisTests
using Pingouin
using DataFrames

function best_parametres()
     for (root, dirs, files) in walkdir("./algorithms/genetyk/jsons")
        for file in files
            f = open("./algorithms/genetyk/jsons/"*file)
            name = file[17:length(file)]
            #name = file[28:length(file)]
            df = JSON.parse(read(f,String))
            best_par = []
            best_result = Inf
            for i in 1:length(df[name])
                result = Inf
                par = df[name][i][2]
                for j in 1:length(df[name][i][3])
                    if df[name][i][3][j][1] < result
                        result = df[name][i][3][j][1]
                    end
                end
                if result < best_result
                    #println(result)
                    best_par = par
                    best_result = result
                end
            end
            println(name)
            println(best_par)
            println(best_result)
        end
    end
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
    return [populacja,selekcja,crossover,mutacja, next_gen]
end

function wykresy()
    problems = ["kroB100.tsp","kroA100.tsp","gr17.tsp","eil101.tsp","eil51.tsp","a280.tsp","lin105.tsp", "berlin52.tsp",
              "ry48p.atsp","p43.atsp","kro124p.atsp","ftv64.atsp","ftv44.atsp","ftv35.atsp","ftv33.atsp","br17.atsp"]
    dicts = separator()
    populacja = dicts[1]
    selekcja = dicts[2]
    selekcja["random"] = selekcja[""]
    pop!(selekcja,"")
    crossover = dicts[3]
    mutacja = dicts[4]
    next_gen = dicts[5]
    odniesienie = parametry_odniesienia()
    testy_populacja = Dict{String,Array}()
    testy_selekcja = Dict{String,Array}()
    testy_crossover = Dict{String,Array}()
    testy_mutacja = Dict{String,Array}()
    testy_next_gen = Dict{String,Array}()
    for problem in problems
        operators = []
        push!(operators,"odniesienie")
        if !haskey(testy_populacja,"odniesienie")
            testy_populacja["odniesienie"] = []
        end
        arrx = []
        arry = []
        push!(odniesienie[problem][1],60*1000)
        push!(odniesienie[problem][2],minimum(odniesienie[problem][2]))
        push!(testy_populacja["odniesienie"], minimum(odniesienie[problem][2])) 
        push!(arry,odniesienie[problem][2])
        push!(arrx,odniesienie[problem][1])
        for (key,value) in populacja
            if !haskey(testy_populacja,key)
                testy_populacja[key] = []
            end
            push!(operators,key)
            value[problem][1][length(value[problem][1])] = value[problem][1][length(value[problem][1])]*1000
            push!(testy_populacja[key],minimum(value[problem][2]))
            push!(arrx,value[problem][1])
            push!(arry,value[problem][2])
        end
        #plotForAny(arrx,arry,"Operatory populacji: instancja $problem",operators,"Milliseconds","Value")
    end
    for problem in problems
        operators = []
        push!(operators,"odniesienie")
        arrx = []
        arry = []
        if !haskey(testy_mutacja,"odniesienie")
            testy_mutacja["odniesienie"] = []
        end
        # push!(odniesienie[problem][1],60*1000)
        # push!(odniesienie[problem][2],minimum(odniesienie[problem][2]))
        push!(arry,odniesienie[problem][2])
        push!(arrx,odniesienie[problem][1])
        push!(testy_mutacja["odniesienie"], minimum(odniesienie[problem][2])) 
        for (key,value) in mutacja
            if !haskey(testy_mutacja,key)
                testy_mutacja[key] = []
            end
            push!(operators,key)
            #value[problem][1][length(value[problem][1])] = value[problem][1][length(value[problem][1])]*1000
            push!(value[problem][1],60000)
            push!(value[problem][2],value[problem][2][length(value[problem][2])])
            #println(value[problem][1])
            push!(testy_mutacja[key],minimum(value[problem][2]))
            push!(arrx,value[problem][1])
            push!(arry,value[problem][2])
            #exit(0)
        end
        #exit(0)
        #plotForAny(arrx,arry,"Operatory mutacji: instancja $problem",operators,"Milliseconds","Value")
        #exit(0)
    end
    for problem in problems
        operators = []
        push!(operators,"odniesienie")
        arrx = []
        arry = []
        if !haskey(testy_crossover,"odniesienie")
            testy_crossover["odniesienie"] = []
        end
        # push!(odniesienie[problem][1],60*1000)
        # push!(odniesienie[problem][2],minimum(odniesienie[problem][2]))
        push!(arry,odniesienie[problem][2])
        push!(arrx,odniesienie[problem][1])
        push!(testy_crossover["odniesienie"], minimum(odniesienie[problem][2]))
        for (key,value) in crossover
            if !haskey(testy_crossover,key)
                testy_crossover[key] = []
            end
            push!(operators,key)
            #value[problem][1][length(value[problem][1])] = value[problem][1][length(value[problem][1])]*1000
            push!(value[problem][1],60000)
            push!(value[problem][2],value[problem][2][length(value[problem][2])])
            #println(value[problem][1])
            push!(arrx,value[problem][1])
            push!(arry,value[problem][2])
            push!(testy_crossover[key],minimum(value[problem][2]))
            #exit(0)
        end
        #exit(0)
        #plotForAny(arrx,arry,"Operatory Krzyżowania: instancja $problem",operators,"Milliseconds","Value")
        #exit(0)
    end
    for problem in problems
        operators = []
        push!(operators,"odniesienie")
        arrx = []
        arry = []
        # push!(odniesienie[problem][1],60*1000)
        # push!(odniesienie[problem][2],minimum(odniesienie[problem][2]))
        push!(arry,odniesienie[problem][2])
        push!(arrx,odniesienie[problem][1])
        if !haskey(testy_selekcja,"odniesienie")
            testy_selekcja["odniesienie"] = []
        end
        push!(testy_selekcja["odniesienie"], minimum(odniesienie[problem][2]))
        for (key,value) in selekcja
            if !haskey(testy_selekcja,key)
                testy_selekcja[key] = []
            end
            push!(operators,key)
            #value[problem][1][length(value[problem][1])] = value[problem][1][length(value[problem][1])]*1000
            push!(value[problem][1],60000)
            push!(value[problem][2],value[problem][2][length(value[problem][2])])
            push!(arrx,value[problem][1])
            push!(arry,value[problem][2])
            push!(testy_selekcja[key],minimum(value[problem][2]))
            #exit(0)
        end
        #exit(0)
        #plotForAny(arrx,arry,"Operatory selekcji: instancja $problem",operators,"Milliseconds","Value")
        #exit(0)
    end
    for problem in problems
        operators = []
        push!(operators,"odniesienie")
        arrx = []
        arry = []
        # push!(odniesienie[problem][1],60*1000)
        # push!(odniesienie[problem][2],minimum(odniesienie[problem][2]))
        push!(arry,odniesienie[problem][2])
        push!(arrx,odniesienie[problem][1])
        if !haskey(testy_next_gen,"odniesienie")
            testy_next_gen["odniesienie"] = []
        end
        push!(testy_next_gen["odniesienie"], minimum(odniesienie[problem][2]))
        for (key,value) in next_gen
            if !haskey(testy_next_gen,key)
                testy_next_gen[key] = []
            end
            push!(operators,key)
            #value[problem][1][length(value[problem][1])] = value[problem][1][length(value[problem][1])]*1000
            push!(value[problem][1],60000)
            push!(value[problem][2],value[problem][2][length(value[problem][2])])
            push!(arrx,value[problem][1])
            push!(arry,value[problem][2])
            push!(testy_next_gen[key],minimum(value[problem][2]))
            #exit(0)
        end
        #exit(0)
        #plotForAny(arrx,arry,"Operatory selekcji: instancja $problem",operators,"Milliseconds","Value")
        #exit(0)
    end
    #statistical_tests(testy_mutacja)
    #statistical_tests(testy_selekcja)
    #statistical_tests(testy_crossover)
    #statistical_tests(testy_populacja)
    statistical_tests(testy_next_gen)
    #println(testy_selekcja)
    # plotForAnyBars(problems,testy_populacja,"Testy wpływu operatorów generowania populacji","numer instancji", "Różnica w %")
    #plotForAnyBars(problems,testy_selekcja,"Testy wpływu operatorów wyboru rodziców","numer instancji", "Różnica w %")
    #plotForAnyBars(problems,testy_crossover,"Testy wpływu operatorów krzyżowania","numer instancji", "Różnica w %")
    #plotForAnyBars(problems,testy_mutacja,"Testy wpływu operatorów mutowania","numer instancji", "Różnica w %")
    plotForAnyBars(problems,testy_next_gen,"Testy wpływu operatorów selekcji następnej generacji","numer instancji", "Różnica w %")
    #println(testy_next_gen)
    exit(0)
end

function statistical_tests(dict::Dict)
    len = 0
    df = DataFrame()
    keys = []
    arrs::Array{Array{Float64,1}} = []
    for (key,val) in dict
        push!(keys,key)
        push!(arrs,val)
        println(key,val)
        df[!,:($key)] = val
    end
    for i in 1:length(arrs)
        for j in i+1:length(arrs)
            println(keys[i])
            println(keys[j])
            #println()
            println(SignedRankTest(arrs[i],arrs[j]))
        end
    end
    #println(df)
    #println(friedman(df,"Row","Desire","1","f"))
end

#parameters_impact()
#wykresy()
function best_parametres_size()
    for (root, dirs, files) in walkdir("./algorithms/genetyk/jsonsRozmiaru")
       for file in files
           f = open("./algorithms/genetyk/jsonsRozmiaru/"*file)
           name = file[8:length(file)]
           #name = file[28:length(file)]
           df = JSON.parse(read(f,String))
           best_par = []
           best_result = Inf
           for i in 1:length(df[name])
               result = Inf
               par = df[name][i][1]
               for j in 1:length(df[name][i][3])
                   if df[name][i][3][j][1] < result
                       result = df[name][i][3][j][1]
                   end
               end
               if result < best_result
                   #println(result)
                   best_par = par
                   best_result = result
               end
           end
           println(name)
           println(best_par)
           println(best_result)
       end
   end
end
best_parametres_size()