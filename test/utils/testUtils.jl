include("../../src/types/json.jl")
include("../../src/types/device.jl")

"""
Generates n junctions connected to shuttles.
repJunction: Repeats a junction ID.
wrongJunctType: Gives a wrong junction type to a shuttle.
isolatedJunc: The first junction is not connected to any shuttle.
"""
function giveShuttlesJunctions(nShuttles:: Int64, juncTypes:: Array{String};
            repJunc=false, wrongJuncType=false, isolatedJunc=false)::
            Tuple{Array{ShuttleInfoJSON,1},Array{JunctionInfoJSON,1}}

    shuttles = ShuttleInfoJSON[]
    junctions = JunctionInfoJSON[]
    sId = 0
    skipShuttle = wrongJuncType
    isolatedJunc = isolatedJunc
    for i in 1:nShuttles
        repJunc ? push!(junctions, JunctionInfoJSON(0, juncTypes[i])) : 
        push!(junctions, JunctionInfoJSON(i, juncTypes[i]))
        if isolatedJunc
            isolatedJunc = false
            continue
        end
        for j in 1:typesSizes[eval(Meta.parse(juncTypes[i]))]
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