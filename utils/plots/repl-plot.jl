using Plots

function myplot(road::Array{Int}, nodes::Matrix, connect::Bool)
    plt = scatter(nodes[:, 1], nodes[:, 2], label=false)
    xaxis = []
    road .|> (x -> push!(xaxis, nodes[x, 1]))
    yaxis = []
    road .|> (x -> push!(yaxis, nodes[x, 2]))
    if connect
        push!(xaxis, xaxis[1])
        push!(yaxis, yaxis[1])
    end
    plt = plot!(xaxis, yaxis, label=false)
    display(plt)
end