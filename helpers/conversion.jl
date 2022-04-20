function structToDict(s)
    return Dict(key => getfield(s, key) for key ∈ propertynames(s))
end
