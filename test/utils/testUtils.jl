include("../../src/types/QCCDevDescription.jl")
include("../../src/types/QCCDevControl.jl")

"""
Generates n junctions connected to shuttles.
repJunction: Repeats a junction ID.
wrongJunctType: Gives a wrong junction type to a shuttle.
isolatedJunc: The first junction is not connected to any shuttle.
"""
function giveShuttlesJunctions(nShuttles:: Int64, juncTypes:: Array{String};
            repJunc=false, wrongJuncType=false, isolatedJunc=false)::
            Tuple{Array{ShuttleInfoDesc,1},Array{JunctionInfoDesc,1}}

    shuttles = ShuttleInfoDesc[]
    junctions = JunctionInfoDesc[]
    sId = 0
    skipShuttle = wrongJuncType
    isolatedJunc = isolatedJunc
    for i in 1:nShuttles
        repJunc ? push!(junctions, JunctionInfoDesc(0, juncTypes[i])) : 
        push!(junctions, JunctionInfoDesc(i, juncTypes[i]))
        if isolatedJunc
            isolatedJunc = false
            continue
        end
        for j in 1:typesSizes[eval(Meta.parse(juncTypes[i]))]
            if skipShuttle
                skipShuttle = false
                continue
            end
            push!(shuttles, ShuttleInfoDesc(string(sId),i,-1))
            sId += 1
        end
    end
    return shuttles, junctions
end

function giveShuttles(nShuttles:: Int64;  repShuttle=false)::Dict{String,Shuttle}
    shuttles = ShuttleInfoDesc[]
    for i in 1:nShuttles
        
    end
end