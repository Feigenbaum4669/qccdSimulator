using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevDes_Types
using Random

"""
Generates n junctions connected to shuttles.
repJunction: Repeats a junction ID.
wrongJunctType: Gives a wrong junction type to a shuttle.
isolatedJunc: The first junction is not connected to any shuttle.
"""
function giveShuttlesJunctions(nJunctions:: Int64, juncTypes:: Array{String};
            repJunc=false, wrongJuncType=false, isolatedJunc=false, repShuttle=false)::
            Tuple{Array{ShuttleInfoDesc},Array{JunctionInfoDesc}}

    shuttles = ShuttleInfoDesc[]
    junctions = JunctionInfoDesc[]
    sId = 0
    skipShuttle = wrongJuncType
    isolatedJunc = isolatedJunc
    for i in 1:nJunctions
        repJunc ? push!(junctions, JunctionInfoDesc(0, juncTypes[i])) : 
        push!(junctions, JunctionInfoDesc(i, juncTypes[i]))
        if isolatedJunc
            isolatedJunc = false
            continue
        end
        for j in 1:typesSizes[Symbol(juncTypes[i])]
            if skipShuttle
                skipShuttle = false
                continue
            end
            push!(shuttles, ShuttleInfoDesc(string(sId),i,-1))
            if repShuttle
                repShuttle = false
                continue
            end
            sId += 1
        end
    end
    return shuttles, junctions
end

"""
Creates some shuttle objects.
"""
function giveShuttles(nShuttles:: Int64;  invShuttle=false)::ShuttleDesc
    shuttles = ShuttleInfoDesc[]
    for i in 1:nShuttles
        if invShuttle
            push!(shuttles,ShuttleInfoDesc("$i",i,i))
            invShuttle = false
        end
        push!(shuttles,ShuttleInfoDesc("$i",i,i+1))
    end
    return ShuttleDesc(shuttles)
end

"""
Creates a struct QCCDevDescription based in the file topology.json
"""
function giveQccDes()::QCCDevDescription
    adjacency:: AdjacencyDesc = AdjacencyDesc(
                    Dict(("4" => [1],"1" => [5],"5" => [2, 3],"2" => [4],"3" => [4]))
    )
    trap:: TrapDesc = TrapDesc(
        3,
        [ 
            TrapInfoDesc( 1, "", "s1"),
            TrapInfoDesc( 2, "s3", ""),
            TrapInfoDesc( 3, "s6", "")
        ]
    )
    junction:: JunctionDesc = JunctionDesc(
        [
            JunctionInfoDesc( 4, "T"),
            JunctionInfoDesc( 5, "T")
        ]
    )
    shuttle:: ShuttleDesc = ShuttleDesc(
        [
            ShuttleInfoDesc( "s1", 1, 5),
            ShuttleInfoDesc( "s2", 5, 2),
            ShuttleInfoDesc( "s3", 2, 4),
            ShuttleInfoDesc( "s4", 4, 1),
            ShuttleInfoDesc( "s5", 5, 3),
            ShuttleInfoDesc( "s6", 3, 4)
        ]
    )
    return  QCCDevDescription(adjacency,trap,junction,shuttle)
end

"""
Gives adjacency list and corresponding set of shuttles.
faultyEnd0, faultyEnd1: Flags for creating shuttles with wrong connections 
"""
function giveShuttlesAdjacency(;faultyEnd0 = false,faultyEnd1 = false)::
    Tuple{Dict{String,Array{Int64}}, Dict{Symbol,Shuttle}}

    adj = Dict{String,Array{Int64}}()
    shuttles = Dict{Symbol,Shuttle}()
    s = 0
    for i in 1:rand(10:30)
        end0 = rand(setdiff(1:100, keys(adj)))
        for j in 1:rand(5:20)
            end1 = rand(setdiff(1:100, [end0]))
            string(end0) in keys(adj) ? push!(adj[string(end0)], end1) :
            adj[string(end0)] = [end1]
            if faultyEnd0
                shuttles[Symbol(s)] = Shuttle(Symbol(s), Symbol(-1), Symbol(end1))
                faultyEnd0 = false
            end
            if faultyEnd0
                shuttles[Symbol(s)] = Shuttle(Symbol(s), Symbol(end0), Symbol(-1))
                faultyEnd1 = false
            end
            shuttles[Symbol(s)] = Shuttle(Symbol(s), Symbol(end0), Symbol(end1))
            s += 1
        end
    end
    return adj, shuttles
end