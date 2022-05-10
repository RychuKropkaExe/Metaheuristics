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