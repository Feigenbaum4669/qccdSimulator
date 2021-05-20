using LightGraphs
using .QCCDevDes_Types
using .QCCDevControl_Types


"""
Creates a dictionary of junctions from JSON objects.
Throws ArgumentError if junction IDs are repeated.
Throws ArgumentError if junction is not connected to anything.
Throws ArgumentError if unsupported junction type is passed.
"""
function _initJunctions(gateZones::Union{Nothing,Array{ZoneInfoDesc}},
    auxZones::Union{Nothing,Array{ZoneInfoDesc}}, loadZones ::Union{Nothing,Array{LoadZoneInfoDesc}},
    junctions::Array{JunctionInfoDesc})::Dict{Symbol,Junction}

    aux = (zone,id) -> !isnothing(zone) ? filter(x -> x.end0 == id || x.end1 == id, zone) : []

    res = Dict{Symbol,Junction}()
    for j ∈ junctions
        haskey(res, Symbol(j.id)) && throw(ArgumentError("Repeated junction ID: $(j.id)."))
        
        connectedGateZones = aux(gateZones,j.id)
        connectedAuxZones = aux(auxZones,j.id)
        connectedLoadZones = aux(loadZones,j.id)

        if isempty(connectedGateZones) && isempty(connectedAuxZones) && isempty(connectedLoadZones)
            throw(ArgumentError("Junction with ID $(j.id) is not connected to anything."))
        end

        ends = Symbol[]
        map(x -> push!(ends,Symbol(x.id)), connectedGateZones)
        map(x -> push!(ends,Symbol(x.id)), connectedAuxZones)
        map(x -> push!(ends,Symbol(x.id)), connectedLoadZones)

        res[Symbol(j.id)] = Junction(Symbol(j.id), Symbol(j.type), ends)
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
Creates a dictionary of loading zones using an object LoadZoneDesc.
Throws ArgumentError if loading zones IDs are repeated.
"""
function _initLoadingZones(loadZoneDesc::LoadZoneDesc)::Dict{Symbol,LoadingZone}
    loadingZonesCtrl = Dict{Symbol, LoadingZone}()
    err = id -> ArgumentError("Repeated loading zone with ID: $id")
    endId = id -> id == "" ? nothing : Symbol(id)

    map(aux -> haskey(loadingZonesCtrl, Symbol(aux.id)) ? throw(err(aux.id)) :
               loadingZonesCtrl[Symbol(aux.id)] = LoadingZone(Symbol(aux.id),
                                             endId(aux.end0), endId(aux.end1)),
               loadZoneDesc.loadZones)
    return loadingZonesCtrl
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
    - Zones are wrong connected
    - Zones don't exist
"""
function _checkInitErrors(junctions:: Dict{String, Junction}, 
                          auxZones::Dict{Symbol,AuxZone},
                          gateZones::Dict{Symbol,GateZone},
                          loadingZones::Dict{Symbol,LoadingZone})

    map(aux -> __auxCheck(aux.end0,aux.end1,gateZones,loadingZones,junctions),
        values(auxZones))
    map(aux -> __auxCheck(aux.end0,aux.end1,auxZones,loadingZones,junctions),
        values(gateZones))
    map(aux -> __auxCheck(aux.end0,aux.end1,auxZones,gateZones,junctions),
        values(loadingZones))

end

function __auxCheck(end0::Symbol, end1::Symbol,
                    zone1::Dict{Symbol,T}, zone2::Dict{Symbol,N},
                     zone3::Dict{Symbol,Z}) where {T, N, Z}

    check = id -> id != nothing &&
                           !(haskey(zone1,id) || haskey(zone2,id) || haskey(zone3,id))
    
    if end0 == nothing && end1 == nothing
        throw(ArgumentError("Topology's elements cannot be isolated"))
    elseif check(zone1,zone2,zone3,end0) || check(zone1,zone2,zone3,end1)
        throw(ArgumentError("Topology's element with ID $key is connected to a non existing element."))

    end
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

########################################################################################################

# Doesn't work && not needed.

# """
# Helper function  for `_initAdjacency`. Takes the current adjacency object and modifies it in-place.
# It adds new connections to the adjacency list if they're not already added.
# """
# function _addToAdjacency(adjacency ::Dict{String, Array{String}}, collection ::Array{T}) where T
#     for element ∈ collection
#         id = element.id
#         end0 = element.end0
#         end1 = element.end1
#         if !haskey(adjacency, end0)
#             adjacency[id] = [end0]
#             if !haskey(adjacency, end1)
#                 push!(adjacency[id], end1)
#             end
#         elseif !haskey(adjacency, end1)
#             adjacency[id] = [end1]
#         end
#     end
# end
# 
# """
# Creates adjacency list from QCCDevCtrl attributes.
# The adjacency list is a dictionary in which the key is the ID of one device component, and the value
# is an array of Ids to the element its adjacent to.
# """
# function _initAdjacency(device ::QCCDevDescription)::Dict{String,Array{String}}
#     adjacency = Dict{String, Array{String}}()
#     _addToAdjacency(adjacency, device.gateZone.gateZones)
#     _addToAdjacency(adjacency, device.auxZone.auxZones)
#     _addToAdjacency(adjacency, device.junction.junctions)
#     _addToAdjacency(adjacency, device.loadZone.loadZones)
#     return adjacency
# end