include("utils.jl")
function swa(a::Array,i,j)
    a[i],a[j] = a[j],a[i]
end
function main(func::Function)
    a = [1,2,3,4,5,6,7,8]
    func(a,2,7)
    println(a)
end
main(swa)