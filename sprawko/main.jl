include("utils.jl")

function main(func::Function)
    a = [1,2,3,4,5,6,7,8]
    func(a,2,7)
    println(a)
end
main(reverse_variant)
main(siema)