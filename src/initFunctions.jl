include("./types/device.jl")
using LightGraphs
import JSON3

"""
Creates a graph using a object topologyJSON.
"""
function initGraph(topology::QCCDevDescription)::SimpleDiGraph{Int64}
    nodesAdjacency::Dict{String,Array{Int64}} = topology.adjacency.nodes
    graphTopology::SimpleDiGraph{Int64} = DiGraph(length(nodesAdjacency))

    for nodes in keys(nodesAdjacency) 
        for node in nodesAdjacency[nodes]
            add_edge!(graphTopology, parse(Int64, nodes), node)
        end
    end
    return graphTopology
end

"""
Creates a dictionary of junctions from JSON objects.
Throws ArgumentError if junction IDs are repeated.
Throws ArgumentError if unsupported junction type is passed.
"""
function initJunctions(shuttles::Array{ShuttleInfoDesc},
            junctions::Array{JunctionInfoDesc})::Dict{Int64,Junction}
    res = Dict{Int64,Junction}()
    for j ∈ junctions
        !haskey(res, j.id) || throw(ArgumentError("Repeated junction ID: $(j.id)."))

        connectedShuttles = filter(x -> x.from == j.id || x.to == j.id, shuttles)
        isempty(connectedShuttles) && throw(ArgumentError("Junction with ID $(j.id) isolated."))
        junctionEnds = Dict(s.id => JunctionEnd() for s ∈ connectedShuttles)
        try
            res[j.id] = Junction(j.id, eval(Meta.parse(j.type)), junctionEnds)
        catch e
            e isa UndefVarError ?
                throw(ArgumentError("Junction type $(j.type) not supported")) : rethrow(e)
        end
    end
    return res
end

"""
Creates a dictionary of shuttles using a object shuttleDesc
Throws ArgumentError if shuttle ID is repeated.
"""
function initShuttles(shuttleDesc::ShuttleDesc)::Dict{String,Shuttle}
    shuttles = Dict{String,Shuttle}()
    err = id -> ArgumentError("Repeated Shuttle ID: $id ")

    map(sh -> haskey(shuttles, sh.id) ? throw(err(sh.id)) :
              shuttles[sh.id] = Shuttle(sh.id, sh.from, sh.to), 
              shuttleDesc.shuttles)
    return shuttles
end

"""
Creates a dictionary of traps using a object trapDesc.
Throws ArgumentError if trap ID is repeated.
"""
function initTraps(trapDesc::TrapDesc)::Dict{Int64,Trap}
    traps = Dict{Int64,Trap}()
    err = id -> ArgumentError("Repeated Trap ID: $id.")

    map(tr -> haskey(traps, tr.id) ? throw(err(tr.id)) :
              traps[tr.id] = Trap(tr.id,trapDesc.capacity,tr.chain, 
              TrapEnd(tr.end0.qubit, tr.end0.shuttle), 
              TrapEnd(tr.end1.qubit, tr.end1.shuttle)), 
              trapDesc.traps)
    return traps
end

"""
Throws error when:
    - Shuttle from - to corresponds JSON adjacency
    - TrapsEnds shuttles exists and shuttle is connected to that trap
    - TrapsEnds qubits is a qubit in the Trap chain and it is in the correct chain position
"""
function checkInitErrors(adjacency:: Dict{String,Array{Int64}}, qubits::Dict{String,Qubit}, 
                      traps::Dict{Int64,Trap}, junctions::Dict{Int64,Junction},
                      shuttles::Dict{String,Shuttle}, graph::SimpleDiGraph{Int64})::QCCDevStat

    _checkShuttles(adjacency,shuttles)
    _checkTraps(traps,shuttles)
end

"""
Throws an error if trapsEnds shuttles exists and shuttle is connected to that trap
"""
function _checkTraps(traps::Dict{Int64,Trap}, shuttles::Dict{String,Shuttle})

    err = trapId-> ArgumentError("Shuttle connected to trap ID $trapId does
                                 not exist or is wrong connected.")

    check = (trEnd,trId) -> isempty(trEnd.shuttle) || (haskey(shuttles, trEnd.shuttle) && 
                            trId in [shuttles[trEnd.shuttle].from, shuttles[trEnd.shuttle].to])

    map(tr-> check(tr.end0,tr.id) && check(tr.end1,tr. id) || throw(err(tr.id))
        ,values(traps))
end

"""
Throws an error if shuttle from - to corresponds JSON adjacency.
"""
function _checkShuttles(adjacency:: Dict{String,Array{Int64}}, shuttles::Dict{String,Shuttle})

    errSh = shuttleId -> ArgumentError("From-to doesn't correspond with adjacency in shuttle 
                                        ID $shuttleId.")
    map(sh ->  haskey(adjacency,string(sh.from)) && sh.to in adjacency[string(sh.from)] ||
                                                            throw(errSh(sh.id)), values(shuttles))
end

########################################################################################################

"""
--> DEPRECATED
Creates a topology using a graph from JSON
"""
function createDevice(path::String)::QCCDevStat
    topology::QCCDevDescription  = _readJSON(path::String)
    junctions = _initJunctions(topology.shuttle.shuttles, topology.junction.junctions)
    qubits = _initQubits(topology.trap)
    shuttles = _initShuttles(topology.shuttle)
    traps = _initTraps(topology.trap)
    graph = _initGraph(topology)
    return  _initQCCDevStat(topology.adjacency.nodes, qubits, traps, junctions, shuttles,graph)
end

"""
--> DEPRECATED
Creates a dictionary of qubits using a object TrapJSON.
Throws ArgumentError if qubit appears in more than one trap.
"""
function _initQubits(trapJSON::TrapJSON)::Dict{String,Qubit}
    qubits = Dict{String,Qubit}()
    err = (trapId, qubitPos, qubitId) -> ArgumentError("Repeated Ion ID: $qubitId
                                                        ,in traps $trapId, $qubitPos.")

    for trap in trapJSON.traps
        map(q -> haskey(qubits, q) ? 
                 throw(err(trap.id, qubits[q].position, qubits[q].id)) :
                 qubits[q] = Qubit(q, resting, trap.id, nothing),
                 trap.chain)
    end
    return qubits
end
