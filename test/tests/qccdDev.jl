include("../utils/testUtils.jl")
using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevControl

function readJSONOK(path::String)::Bool
    qccd1 = readJSON(path) 
    qccd2 = giveQccDes()
    return checkEqualQCCD(qccd1,qccd2)
end

function QCCDevCtrlOKTest()::Bool
    qccd1 = giveQccCtrl()
    qccd2 = QCCDevCtrl(giveQccDes())
    return checkEqualQCCDevCtrl(qccd1,qccd2)
end

function checkEqualQCCD(qccd1::QCCDevDescription, qccd2::QCCDevDescription):: Bool
    # Compare gate zones
    gateZones1 = qccd1.gateZone.gateZones
    gateZones2 = qccd2.gateZone.gateZones
    @assert size(gateZones1) == size(gateZones2)
    for (gateZone1,gateZone2) in zip(gateZones1,gateZones2)
        @assert gateZone1.id == gateZone2.id
        @assert gateZone1.end0 == gateZone2.end0
        @assert gateZone1.end1 == gateZone2.end1
        @assert gateZone1.capacity == gateZone2.capacity
    end
    # Compare auxiliary zones
    auxZones1 = qccd1.auxZone.auxZones
    auxZones2 = qccd2.auxZone.auxZones
    @assert size(auxZones1) == size(auxZones2)
    for (auxZone1,auxZone2) in zip(auxZones1,auxZones2)
        @assert auxZone1.id == auxZone2.id
        @assert auxZone1.end0 == auxZone2.end0
        @assert auxZone1.end1 == auxZone2.end1
        @assert auxZone1.capacity == auxZone2.capacity
    end
    # Compare junctions
    juns1 = qccd1.junction.junctions
    juns2 = qccd2.junction.junctions
    @assert size(juns1) == size(juns2)
    for (jun1,jun2) in zip(juns1,juns2)
        @assert jun1.id == jun2.id
        @assert jun1.type == jun2.type
    end
    # Compare loading zones
    loadZones1 = qccd1.loadZone.loadZones
    loadZones2 = qccd2.loadZone.loadZones
    @assert size(loadZones1) == size(loadZones2)
    for (loadZone1,loadZone2) in zip(loadZones1,loadZones2)
        @assert loadZone1.id == loadZone2.id
        @assert loadZone1.end0 == loadZone2.end0
        @assert loadZone1.end1 == loadZone2.end1
    end
    return true
end

function checkEqualQCCDevCtrl(qccdc1::QCCDevCtrl,qccdc2::QCCDevCtrl):: Bool
    @assert qccdc1.t_now == qccdc2.t_now
    @assert checkEqualQCCD(qccdc1.dev, qccdc2.dev)
    @assert nv(qccdc1.graph) == nv(qccdc2.graph)
    @assert ne(qccdc1.graph) == ne(qccdc2.graph)
    @assert length(qccdc1.traps) == length(qccdc2.traps)
    @assert length(qccdc1.junctions) == length(qccdc2.junctions)
    @assert length(qccdc1.shuttles) == length(qccdc2.shuttles)
    for (key,value) in qccdc1.traps
        @assert haskey(qccdc2.traps, key)
        @assert qccdc2.traps[key].id == value.id
        @assert qccdc2.traps[key].capacity == value.capacity
        @assert qccdc2.traps[key].chain == value.chain
        @assert qccdc2.traps[key].end0.qubit == value.end0.qubit
        @assert qccdc2.traps[key].end0.shuttle == value.end0.shuttle
        @assert qccdc2.traps[key].end1.qubit == value.end1.qubit
        @assert qccdc2.traps[key].end1.shuttle == value.end1.shuttle
        @assert qccdc2.traps[key].gate == value.gate
        @assert qccdc2.traps[key].loading_hole == value.loading_hole
    end
    for (key,value) in qccdc1.shuttles
        @assert haskey(qccdc2.shuttles, key)
        @assert qccdc2.shuttles[key].id == value.id
        @assert qccdc2.shuttles[key].end0 == value.end0
        @assert qccdc2.shuttles[key].end1 == value.end1
    end
    for (key,value) in qccdc1.junctions
        @assert haskey(qccdc2.junctions, key)
        @assert qccdc2.junctions[key].id == value.id
        @assert qccdc2.junctions[key].type == value.type
        for (k,v) in qccdc1.junctions[key].ends
            @assert haskey(qccdc1.junctions[key].ends,k)
            @assert qccdc1.junctions[key].ends[k].qubit == v.qubit
            @assert qccdc1.junctions[key].ends[k].status == v.status
        end
    end
    return true
end

function initGateZoneTest()
    gateZoneDesc::GateZoneDesc = giveQccDes().gateZone
    gateZones = qccdSimulator.QCCDevControl._initGateZone(gateZoneDesc)
    for (key, value) in gateZones
        @assert key == value.id
        aux = filter(x-> Symbol(x.id)==key, gateZoneDesc.gateZones)
        @assert length(aux) == 1
        @assert aux.capacity == value.capacity
        @assert isempty(value.chain)
        tmp = aux.end0 == "" ? nothing : Symbol(aux.end0)
        @assert tmp == value.end0
        tmp = aux.end1 == "" ? nothing : Symbol(aux.end1)
        @assert tmp == value.end1
    end
    return true
end

function initGateZoneRepeatedIdTest()
    trapDesc::TrapDesc = giveGateZoneDescRepeatedId()
    return qccdSimulator.QCCDevControl._initTraps(trapDesc)
end

function checkTrapsTest()
    qdd::QCCDevCtrl = giveQccCtrl()
    qccdSimulator.QCCDevControl._checkTraps(qdd.traps,qdd.shuttles)
    return true
end

function checkTrapsShuttleNotExistTest()
    qdd::QCCDevCtrl = giveQccCtrl()
    traps::Dict{Symbol,Trap} = qccdSimulator.QCCDevControl._initTraps(giveGateZoneDescNoConnection())
    qccdSimulator.QCCDevControl._checkTraps(traps,qdd.shuttles)
    return true
end

function checkTrapsShuttleWrongConnectedTest()
    qdd::QCCDevCtrl = giveQccCtrl()
    traps::Dict{Symbol,Trap} = qccdSimulator.QCCDevControl._initTraps(giveGateZoneDescWrongConnectedShuttle())
    qccdSimulator.QCCDevControl._checkTraps(traps,qdd.shuttles)
    return true
end

function initJunctionsTest()
    _typeSizes = Dict(:T => 3, :Y => 3, :X => 4)
    shuttles, _junctions = giveShuttlesJunctions(9, ["X", "Y", "T","X", "Y", "T","X", "Y", "T"])
    junctions = qccdSimulator.QCCDevControl._initJunctions(shuttles, _junctions)
    for (k,junction) in junctions
        @assert k == junction.id
        juncType = filter(x-> Symbol(x.id)==k,_junctions)[1].type
        juncType = Symbol(juncType)
        @assert junction.type == juncType
        shuttleIds = keys(junction.ends)
        @assert length(shuttleIds) == _typeSizes[juncType]
        for shuttleId in shuttleIds
            shuttle = filter(x -> Symbol(x.id) == shuttleId, shuttles)[1]
            @assert Symbol(string(shuttle.end0)) == k || Symbol(shuttle.end1) == k
        end
    end
    return true
end

function initJunctionsTestRepId()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];repJunc = true)
    junctions = qccdSimulator.QCCDevControl._initJunctions(shuttles, _junctions)
end

function initJunctionsTestIsolated()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];isolatedJunc = true)
    junctions = qccdSimulator.QCCDevControl._initJunctions(shuttles, _junctions)
end

function initJunctionsTestWrongType()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];wrongJuncType = true)
    junctions = qccdSimulator.QCCDevControl._initJunctions(shuttles, _junctions)
end

function initAuxZonesTestRepId()
    auxZones, _ = giveAuxZonesJunctions(2, ["T","T"];repShuttle = true)
    shDesc = AuxZoneDesc(auxZones)
    qccdSimulator.QCCDevControl._initAuxZones(shDesc)
end

function initAuxZonesTestInvAuxZone()
    qccdSimulator.QCCDevControl._initAuxZones(giveAuxZones(5;invAuxZones=true))
end

function initAuxZonesTest()
    _auxZones = giveShuttles(10)
    auxZones = qccdSimulator.QCCDevControl._initShuttles(_auxZones)
    @assert length(_auxZones.auxZones) == length(auxZones)
    for _auxZone in _auxZones.auxZones
        auxZone = shuttles[Symbol(_shuttle.id)]
        @assert _auxZone.end0 == parse(Int,string(auxZone.end0))
        @assert _auxZone.end1 == parse(Int,string(auxZone.end1))
    end
    return true
end

function QCCDevCtrlTest()
    qdd::QCCDevDescription = giveQccDes()
    return QCCDevCtrl(qdd)
end

function checkAuxZonesTest()
    adj, auxZones = giveAuxZonesAdjacency()
    qccdSimulator.QCCDevControl._checkAuxZones(adj, auxZones)
    return true
end

function checkAuxZonesTestMissingAdj()
    adj, auxZones = giveAuxZonesAdjacency()
    try 
        qccdSimulator.QCCDevControl._checkAuxZones(delete!(adj, collect(keys(adj))[1]), shutauxZonestles)
    catch e
        @assert e.msg == "Number of elements in adjacency list and number of auxZones don't match"
    end
    return true
end

function checkAuxZonesTestMissingAuxZone()
    adj, auxZones = giveAuxZonesAdjacency()
    try 
        qccdSimulator.QCCDevControl.
                    _checkAuxZones(adj, delete!(auxZones, collect(keys(auxZones))[1]))
    catch e
        @assert e.msg == "Number of elements in adjacency list and number of auxZones don't match"
    end
    return true
end

"""Checks all combinations for _checkAuxZones check function"""
function checkAuxZonesTestModifyConnections()
    adj, auxZones = giveAuxZonesAdjacency()
    
    # Tamper a 'random' key in the dictionary
    _adj = deepcopy(adj)
    k = collect(keys(_adj))[1]
    _adj[k*"_"] = _adj[k] 
    delete!(_adj, k) # So there isn't a size mismatch
    try
        qccdSimulator.QCCDevControl._checkAuxZones(_adj, auxZones)
    catch e
        @assert startswith(e.msg, "Ends don't correspond to adjacency in auxZone ID")
    end
    _adj = nothing

    # Tamper a random value in the dictionary
    _adj = deepcopy(adj)
    _adj[rand(keys(_adj))][1] = -1 
    try
        qccdSimulator.QCCDevControl._checkShuttles(_adj, auxZones)
    catch e
        @assert startswith(e.msg, "Ends don't correspond to adjacency in auxZone ID")
    end
    _adj = nothing

    # An end0 is going to be wrong
    adj, auxZones = giveAuxZonesAdjacency(;faultyEnd0=true)
    try
        qccdSimulator.QCCDevControl._checkAuxZones(adj, auxZones)
    catch e
        @assert startswith(e.msg, "Ends don't correspond to adjacency in auxZone ID")
    end

    # An end1 is going to be wrong
    adj, auxZones = giveAuxZonesAdjacency(;faultyEnd1=true)
    try
        qccdSimulator.QCCDevControl._checkAuxZones(adj, auxZones)
    catch e
        @assert startswith(e.msg, "Ends don't correspond to adjacency in auxZone ID")
    end

    return true
end

function readTimeJSONOK(path ::String)
    readTimeJSON(path)
    @assert OperationTimes[:load] == 5
    @assert OperationTimes[:linear_transport] == 78
    @assert OperationTimes[:loadingHole_transport] == 35
    @assert OperationTimes[:swap] == 2
    @assert OperationTimes[:split] == 55
    return true
end

function readTimeJSONfail(paths ::Array{String})
   errormsg1 = "Time values can't be negative"
   errormsg2 = "invalid JSON"
   errorcount = 0
   for path ∈ paths
        try
            readTimeJSON(path)
        catch e
            @assert startswith(e.msg, errormsg1) || startswith(e.msg, errormsg2)
            errorcount += 1
        end
   end
   @assert errorcount == length(paths)
   return true
end

function readTimeJSONnoFile()
    try
        readTimeJSON("foo")
    catch e
        @assert startswith(e.msg, "Input is not a file")
    end
    
    return true
end