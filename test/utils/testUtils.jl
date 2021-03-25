include("../../src/types/json.jl")
include("../../src/types/device.jl")

"""
Generates n shuttles connected to shuttles.
repJunction: Repeats a junction ID.
wrongJunctType: Gives a wrong junction type to a shuttle.
"""
function giveShuttlesJunctions(nShuttles:: Int64, juncTypes:: Array{String};
            repJunction=false, wrongJunctType=false):: Tuple{Array{ShuttleInfoJSON,1},Array{JunctionInfoJSON,1}}
    _typesSizes = Dict(T => 3, Y => 3, X => 4)
    shuttles = ShuttleInfoJSON[]
    junctions = JunctionInfoJSON[]
    sId = 0
    skipShuttle = wrongJunctType
    for i in 1:nShuttles
        repJunction ? push!(junctions, JunctionInfoJSON(0, juncTypes[i])) : 
        push!(junctions, JunctionInfoJSON(i, juncTypes[i]))
        for j in 1:_typesSizes[eval(Meta.parse(juncTypes[i]))]
            if skipShuttle
                skipShuttle = false
                continue
            end
            push!(shuttles, ShuttleInfoJSON(string(sId),i,-1))
            sId += 1
        end
    end
    return shuttles, junctions
end

function giveShuttles(nShuttles:: Int64;  repShuttle=false)::Dict{String,Shuttle}
    shuttles = ShuttleInfoJSON[]
    for i in 1:nShuttles
        
    end
end