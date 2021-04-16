using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevDes_Types
using qccdSimulator.QCCDevControl

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
        for j in 1:typesSizes[Symbol(juncTypes[i])]
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
Creates a struct QCCDevCtrl based in the file giveQccDes()
"""
function giveQccCtrl()::QCCDevCtrl
    qccd::QCCDevDescription = giveQccDes()
    traps = Dict{Symbol,Trap}()
    map(tr -> traps[Symbol(tr.id)] = Trap(Symbol(tr.id), qccd.trap.capacity,
                              TrapEnd(Symbol(tr.end0)), TrapEnd(Symbol(tr.end1))),
              qccd.trap.traps)
    shuttles = Dict{Symbol,Shuttle}()
    map(sh -> shuttles[Symbol(sh.id)] = Shuttle(Symbol(sh.id), Symbol(sh.from), Symbol(sh.to)),
              qccd.shuttle.shuttles)
    junctions = Dict{Symbol,Junction}()
    for j ∈ qccd.junction.junctions
        connectedShuttles = filter(x -> x.from == j.id || x.to == j.id, qccd.shuttle.shuttles)
        junctionEnds = Dict(Symbol(s.id) => JunctionEnd() for s ∈ connectedShuttles)
        junctions[Symbol(j.id)] = Junction(Symbol(j.id), Symbol(j.type), junctionEnds)
    end
    nodesAdjacency::Dict{String,Array{Int64}} = qccd.adjacency.nodes
    graph::SimpleDiGraph{Int64} = DiGraph(length(nodesAdjacency))
    for nodes in keys(nodesAdjacency) 
        for node in nodesAdjacency[nodes]
            add_edge!(graph, parse(Int64, nodes), node)
        end
    end
    return QCCDevCtrl(qccd,0,traps,junctions,shuttles, graph)
end
