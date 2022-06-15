using Random
using PyPlot
using TimesDates, CompoundPeriods, TimeZones, Dates



function plotForOne(arrx::Array, arry::Array, t::String, xl::String, yl::String)
    plot(arrx,arry)
    legend()
    xlabel(xl)
    ylabel(yl)
    title(t)
    show()
end
function plotForTwo(arrx::Array, arry::Array, arry2::Array, t::String, xl::String, yl::String, firstPlot::String, secondPlot::String)
    plot(arrx,arry, label = firstPlot)
    plot(arrx,arry2, label = secondPlot)
    legend()
    xlabel(xl)
    ylabel(yl)
    title(t)
    show()
end

function plotForAny(arrx::Array,arry::Array,title1::String,t::Array,xl::String,yl::String)
    #maxs = []
    # for i in 1:length(arry)
    #     push!(maxs,maximum(arry[i]))
    # end
    for i in 1:length(arry)
        plot(arrx[i],arry[i], label = t[i])
        #axis([arrx[1],arrx[length(arrx)],0,maximum(maxs)])
    end
    legend()
    xlabel(xl)
    ylabel(yl)
    title(title1)
    show()
end
function plotForAnyBars(arrx::Array,dict::Dict,title1::String,xl::String,yl::String)
    println(dict)
    odniesienie = dict["odniesienie"]
    arry = [] 
    t = []
    println(length(odniesienie))
    #push!(arry,odniesienie)
    for (key,value) in dict
        if key != "odniesienie"
            if key == "Macarena"
                push!(t,"IRGIBNNM")
            else
                push!(t,key)
            end
            arr = value
            for i in 1:length(arr)
                arr[i] = ((odniesienie[i] - arr[i])/odniesienie[i])*100
            end
            push!(arry,arr)
        end
    end

    arx = Array{Float64,1}(1:16)
    sep = [0,0.25,-0.25,0.50,-0.50,0.75,-0.75]
    for i in 1:length(arry)
        bar(arx.+sep[i],arry[i], label = t[i], width = 0.25)
    end
    legend()
    axhline(0,color = "black", linewidth = 1)
    xticks(arx)
    xlabel(xl)
    ylabel(yl)
    title(title1)
    show()
end

function plotForFour(arrx::Array, arry::Array, arry2::Array,arry3::Array,arry4::Array,t::String, xl::String, yl::String, firstPlot::String, secondPlot::String, thirdPlot::String, fourthPlot::String)
    plot(arrx,arry, label = firstPlot)
    plot(arrx,arry2, label = secondPlot)
    plot(arrx,arry3, label = thirdPlot)
    plot(arrx,arry4, label = fourthPlot)
    legend()
    xlabel(xl)
    ylabel(yl)
    title(t)
    show()
end