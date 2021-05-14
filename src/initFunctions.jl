using LightGraphs
using .QCCDevDes_Types
using .QCCDevControl_Types


"""
Helper function  for `_initAdjacency`. Takes the current adjacency object and modifies it in-place.
It adds new connections to the adjacency list if they're not already added.
"""
function _addToAdjacency(adjacency ::Dict{String, Array{String}}, collection ::Array{T}) where T
    for element ∈ collection
        id = element.id
        end0 = element.end0
        end1 = element.end1
        if !haskey(adjacency, end0)
            adjacency[id] = [end0]
            if !haskey(adjacency, end1)
                push!(adjacency[id], end1)
            end
        elseif !haskey(adjacency, end1)
            adjacency[id] = [end1]
        end
    end
end

"""
Creates adjacency list from QCCDevCtrl attributes.
The adjacency list is a dictionary in which the key is the ID of one device component, and the value
is an array of Ids to the element its adjacent to.
"""
function _initAdjacency(device ::QCCDevDescription)::Dict{String,Array{String}}
    adjacency = Dict{String, Array{String}}()
    _addToAdjacency(adjacency, device.gateZone)
    _addToAdjacency(adjacency, device.auxZone)
    _addToAdjacency(adjacency, device.junction)
    _addToAdjacency(adjacency, device.loadZone)
    return adjacency
end

"""
Creates a dictionary of junctions from JSON objects.
Throws ArgumentError if junction IDs are repeated.
Throws ArgumentError if unsupported junction type is passed.
"""
function _initJunctions(shuttles::Array{AuxZone},
            junctions::Array{JunctionInfoDesc})::Dict{Symbol,Junction}
    res = Dict{Symbol,Junction}()
    for j ∈ junctions
        !haskey(res, Symbol(j.id)) || throw(ArgumentError("Repeated junction ID: $(j.id)."))

        connectedShuttles = filter(x -> x.end0 == j.id || x.end1 == j.id, shuttles)
        isempty(connectedShuttles) && throw(ArgumentError("Junction with ID $(j.id) isolated."))
        junctionEnds = Dict(Symbol(s.id) => JunctionEnd() for s ∈ connectedShuttles)
        res[Symbol(j.id)] = Junction(Symbol(j.id), Symbol(j.type), junctionEnds)
    end
    return res
end

"""
Creates a dictionary of auxiliary zones using an object AuxZoneDesc.
Throws ArgumentError if auxiliary zones IDs are repeated.
"""
function _initAuxZones(auxZoneDesc::AuxZoneDesc)::Dict{Symbol,AuxZone}
    auxZonesCtrl = Dict{Symbol,AuxZone}()
    err = id -> ArgumentError("Repeated auxiliary zone ID: $id ")
    endId = id -> id == "" ? nothing : Symbol(id)

    map(aux -> haskey(auxZonesCtrl, Symbol(aux.id)) ? throw(err(aux.id)) :
              auxZonesCtrl[Symbol(aux.id)] = AuxZone(Symbol(aux.id), aux.capacity,
                                                    endId(aux.end0), endId(aux.end1)),
              auxZoneDesc.auxZones)
    return auxZonesCtrl
end

"""
Creates a dictionary of traps using a object trapDesc.
Throws ArgumentError if trap ID is repeated.
"""
function _initGateZone(gateZoneDesc::GateZoneDesc)::Dict{Symbol,GateZone}
    gateZonessCtrl = Dict{Symbol,GateZone}()
    err = id -> ArgumentError("Repeated gate zone with ID: $id.")
    endId = id -> id == "" ? nothing : Symbol(id)

    map(tr -> haskey(gateZonessCtrl, Symbol(tr.id)) ? throw(err(tr.id)) :
                     gateZonessCtrl[Symbol(tr.id)] = GateZone(Symbol(tr.id), tr.capacity,
                     endId(tr.end0), endId(tr.end1)),
             gateZoneDesc.gateZones)
             
    return gateZonessCtrl
end

"""
Throws error when:
    - Shuttle ends don't correspond to JSON adjacency
    - Throws an error if trapsEnds shuttles don't exists or don't correspond with Shuttle adjacency
"""
function _checkInitErrors(adjacency:: Dict{String, Array{Int64}}, 
                          gateZones::Dict{Symbol,GateZoneDesc},
                          auxZones::Dict{Symbol,AuxZone})

    _checkAuxZones(adjacency,auxZones)
    _checkGateZones(gateZones,auxZones)
end

"""
Throws an error if trapsEnds shuttles don't exists or don't correspond with Shuttle adjacency
"""
function _checkGateZones(traps::Dict{Symbol,GateZone}, shuttles::Dict{Symbol,AuxZone})

    err = trapId-> ArgumentError("Shuttle connected to trap ID $trapId does "*
                                 "not exist or is wrong connected.")

    check = (trEnd,trId) -> trEnd.shuttle isa Nothing || (haskey(shuttles, trEnd.shuttle) && 
                            trId in [shuttles[trEnd.shuttle].end0, shuttles[trEnd.shuttle].end1])

    map(tr-> check(tr.end0,tr.id) && check(tr.end1,tr. id) || throw(err(tr.id))
        ,values(traps))
end

"""
Throws an error if shuttle ends don't correspond JSON adjacency.
"""
function _checkAuxZones(adjacency:: Dict{String, Array{Int64}}, shuttles::Dict{Symbol,AuxZone})

    errSh = shuttleId -> ArgumentError("Ends don't correspond to adjacency in shuttle "*
                                        "ID $shuttleId.")
    length(shuttles) == sum(length, values(adjacency)) ||
        throw(ArgumentError(
            "Number of elements in adjacency list and number of shuttles don't match"))
            
    check = sh ->
        (haskey(adjacency,string(sh.end0)) && parse(Int,string(sh.end1)) in adjacency[string(sh.end0)]) ||
        (haskey(adjacency,string(sh.end1)) && parse(Int,string(sh.end0)) in adjacency[string(sh.end1)])

    map(sh ->  check(sh) || throw(errSh(sh.id)), values(shuttles))
end

########################################################################################################

"""
--> DEPRECATED
Creates a dictionary of qubits using a object TrapJSON.
Throws ArgumentError if qubit appears in more than one trap.
"""
function initQubits(trapDesctraps::GateZone)::Dict{String,Qubit}
    qubits = Dict{String,Qubit}()
    err = (trapId, qubitPos, qubitId) -> ArgumentError("Repeated Ion ID: $qubitId
                                                        ,in traps $trapId, $qubitPos.")

    for trap in trapDesctraps.traps
        map(q -> haskey(qubits, q) ? 
                 throw(err(trap.id, qubits[q].position, qubits[q].id)) :
                 qubits[q] = Qubit(q, :resting, trap.id, nothing),
                 trap.chain)
    end
    return qubits
end


"""
--> DEPRECATED
Creates a graph using an object QCCDevDescription.
Throws ArgumentError if LightGraphs fails to add a node. This will happen
    if there are redundancies in the adjacency list (i.e. repeated edges),
    so maybe is not worth having.
"""
function initGraph(topology::QCCDevDescription)::SimpleGraph{Int64}
    nodesAdjacency::Dict{String,Array{Int64}} = topology.adjacency.nodes
    graph::SimpleGraph{Int64} = SimpleGraph(length(nodesAdjacency))

    for nodes in keys(nodesAdjacency) 
        for node in nodesAdjacency[nodes]
            stat = add_edge!(graph, parse(Int64, nodes), node)
            stat || throw(ArgumentError("Failed adding edge ($nodes,$node) to graph."))
        end
    end
    return graph
end