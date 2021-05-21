include("../utils/testUtils.jl")
using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevControl

# ========= JSON tests =========
function readJSONOK(path::String)::Bool
    qccd1 = readJSON(path) 
    qccd2 = giveQccDes()
    return checkEqualQCCD(qccd1,qccd2)
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
# ========= END JSON tests =========


# ========= Device comparison tests =========
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
    @assert qccdc1.simulate == qccdc2.simulate
    @assert qccdc1.qnoise_esimate == qccdc2.qnoise_esimate
    @assert checkEqualQCCD(qccdc1.dev, qccdc2.dev)
    @assert length(qccdc1.gateZones) == length(qccdc2.gateZones)
    @assert length(qccdc1.junctions) == length(qccdc2.junctions)
    @assert length(qccdc1.auxZones) == length(qccdc2.auxZones)
    @assert length(qccdc1.loadingZones) == length(qccdc2.loadingZones)
    for (key,value) in qccdc1.gateZones
        @assert haskey(qccdc2.gateZones, key)
        @assert qccdc2.gateZones[key].id == value.id
        @assert qccdc2.gateZones[key].capacity == value.capacity
        @assert qccdc2.gateZones[key].chain == value.chain
        @assert qccdc2.gateZones[key].end0 == value.end0
        @assert qccdc2.gateZones[key].end1 == value.end1
    end
    for (key,value) in qccdc1.auxZones
        @assert haskey(qccdc2.auxZones, key)
        @assert qccdc2.auxZones[key].id == value.id
        @assert qccdc2.auxZones[key].capacity == value.capacity
        @assert qccdc2.auxZones[key].chain == value.chain
        @assert qccdc2.auxZones[key].end0 == value.end0
        @assert qccdc2.auxZones[key].end1 == value.end1
    end
    for (key,value) in qccdc1.loadingZones
        @assert haskey(qccdc2.loadingZones, key)
        @assert qccdc2.loadingZones[key].id == value.id
        @assert qccdc2.loadingZones[key].end0 == value.end0
        @assert qccdc2.loadingZones[key].end1 == value.end1
        @assert qccdc2.loadingZones[key].hole == value.hole == nothing
    end
    for (key,value) in qccdc1.junctions
        @assert haskey(qccdc2.junctions, key)
        @assert qccdc2.junctions[key].id == value.id
        @assert qccdc2.junctions[key].ends == value.ends
        @assert qccdc2.junctions[key].type == value.type
    end
    return true
end

function QCCDevCtrlTest()
    qdd::QCCDevDescription = giveQccDes()
    return QCCDevCtrl(qdd)
end
# ========= END Device comparison tests =========


# ========= Junction tests =========
function initJunctionsTest()
    nJunctions = rand(5:30)
    juncTypes = [string(type) for type ∈ JunctionType]
    zones, _junctions = giveZonesJunctions(nJunctions, rand(juncTypes, nJunctions))
    #Convert the generic zones to Gate, auxiliary, and loading zones.
    gateZones = ZoneInfoDesc[]
    auxZones = ZoneInfoDesc[]
    loadZones = LoadZoneInfoDesc[]
    for zone ∈ zones
        r = rand()
        if 0 ≤ r ≤ 0.33
            push!(gateZones, zone)
        elseif 0.33 < r ≤ 0.66
            push!(auxZones, zone)
        else
            load = LoadZoneInfoDesc(zone.id,zone.end0,zone.end1)
            push!(loadZones, load)
        end
    end

    junctions = qccdSimulator.QCCDevControl._initJunctions(gateZones,
                                            auxZones, loadZones, _junctions)
    for (k,junction) in junctions
        @assert k == junction.id
        juncType = filter(x-> Symbol(x.id)==k,_junctions)[1].type #[1] : get first and only element
        juncType = Symbol(juncType)
        @assert junction.type == juncType
        @assert length(junction.ends) == typesSizes[juncType]
        for zoneId in junction.ends
            zone = filter(x -> Symbol(x.id) == zoneId, zones)[1] #[1] : get first and only element
            @assert Symbol(zone.end0) == k || Symbol(zone.end1) == k
        end
    end
    return true
end

function initJunctionsTestRepId()
    zones, _junctions = giveZonesJunctions(2, ["T","T"];repJunc = true)
    try
        qccdSimulator.QCCDevControl._initJunctions(zones, nothing, nothing, _junctions)
    catch e
        @assert startswith(e.msg, "Repeated junction ID")
        return true
    end
    return false
end



function initJunctionsTestIsolated()
    zones, _junctions = giveZonesJunctions(2, ["T","T"];isolatedJunc = true)
    try
        qccdSimulator.QCCDevControl._initJunctions(nothing, zones, nothing, _junctions)
    catch e
        @assert endswith(e.msg, "is not connected to anything.")
        return true
    end
    return false
end

function initJunctionsTestWrongType()
    zones, _junctions = giveZonesJunctions(2, ["T","T"];wrongJuncType = true)
    loadZones = LoadZoneInfoDesc[]
    for zone ∈ zones
        load = LoadZoneInfoDesc(zone.id,zone.end0,zone.end1)
        push!(loadZones, load)
    end
    try
        qccdSimulator.QCCDevControl._initJunctions(nothing,nothing,loadZones, _junctions)
    catch e
        @assert(e.msg == "Junction with ID 1 of type T has 2 ends. It should have 3 ends.")
        return true
    end
    return false
end
# ========= END Junction tests =========

# ========= Adjacency tests  =========
function initAdjacencyTest()
    device ::QCCDevDescription = giveQccDes()
    adjacency = qccdSimulator.QCCDevControl._initAdjacency(device)

    @show adjacency

    for (key, value) in adjacency
        auxGate = filter(x-> Symbol(x.id)==key, device.gateZone.gateZones)
        auxLoad = filter(x-> Symbol(x.id)==key, device.loadZone.loadZones)
        auxAux = filter(x-> Symbol(x.id)==key, device.auxZone.auxZones)
        if !isempty(auxGate)
            @assert sort(value) == sort([auxGate[0].end0, auxGate[0].end1])
        elseif !isempty(auxLoad)
            @assert sort(value) == sort([auxLoad[0].end0, auxLoad[0].end1])
        elseif !isempty(auxAux)
            @assert sort(value) == sort([auxAux[0].end0, auxAux[0].end1])
        end
    end
end


# ========= END Adjacency tests  =========

# ========= Loading zones tests =========
function initLoadingZoneTest()
    loadZoneDesc::LoadZoneDesc = giveQccDes().loadZone
    loadZones = qccdSimulator.QCCDevControl._initLoadingZones(loadZoneDesc)
    for (key, value) in loadZones
        @assert key == value.id
        aux = filter(x-> Symbol(x.id)==key, loadZoneDesc.loadZones)
        @assert length(aux) == 1
        aux = aux[1]
        tmp = aux.end0 == "" ? nothing : Symbol(aux.end0)
        @assert tmp == value.end0
        tmp = aux.end1 == "" ? nothing : Symbol(aux.end1)
        @assert tmp == value.end1
    end
    return true
end

function initLoadingZoneRepeatedIdTest()
    loadZoneDesc::LoadZoneDesc = giveLoadZoneDescRepeatedId()
    return qccdSimulator.QCCDevControl._initLoadingZones(loadZoneDesc)
end
# ========= END Loading zones tests =========

# ========= Auxiliary and Gate zones tests =========
function initGateZoneTest()
    gateZoneDesc::GateZoneDesc = giveQccDes().gateZone
    gateZones = qccdSimulator.QCCDevControl._initGateZone(gateZoneDesc)
    for (key, value) in gateZones
        @assert key == value.id
        aux = filter(x-> Symbol(x.id)==key, gateZoneDesc.gateZones)
        @assert length(aux) == 1
        aux = aux[1]
        @assert aux.capacity == value.capacity
        @assert length(value.chain) == 1 && isempty(value.chain[1]) 
        tmp = aux.end0 == "" ? nothing : Symbol(aux.end0)
        @assert tmp == value.end0
        tmp = aux.end1 == "" ? nothing : Symbol(aux.end1)
        @assert tmp == value.end1
    end
    return true
end

function initGateZoneRepeatedIdTest()
    gateZoneDesc::GateZoneDesc = giveGateZoneDescRepeatedId()
    return qccdSimulator.QCCDevControl._initGateZone(gateZoneDesc)
end

function checkGateZonesAuxZoneNotExistTest()
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



function initAuxGateZonesTestRepId()
    zones, _ = giveZonesJunctions(2, ["T","T"];repZone = true)
    auxDesc = AuxZoneDesc(zones)
    try
        qccdSimulator.QCCDevControl._initAuxZones(auxDesc)
    catch e
        @assert startswith(e.msg, "Repeated")
    end
    gateDesc = GateZoneDesc(zones)
    try
        qccdSimulator.QCCDevControl._initGateZone(gateDesc)
    catch e
        @assert startswith(e.msg, "Repeated")
    end
    return true
end

function initAuxGateZonesTestInvZone()
    try
        qccdSimulator.QCCDevControl._initAuxZones(AuxZoneDesc(giveZoneInfo(rand(5:10);invZone=true)))
    catch e
        @assert endswith(e.msg, "\"end0\" and \"end1\" must be different")
    end
    try
        qccdSimulator.QCCDevControl._initGateZone(GateZoneDesc(giveZoneInfo(rand(5:10);invZone=true)))
    catch e
        @assert endswith(e.msg, "\"end0\" and \"end1\" must be different")
    end
    return true
end

function initAuxGateZonesTestWithNothing()
    zones = giveZoneInfo(rand(5:10);giveNothing=true)
    qccdSimulator.QCCDevControl._initAuxZones(AuxZoneDesc(zones))
    qccdSimulator.QCCDevControl._initGateZone(GateZoneDesc(zones))
    return true
end

function initAuxZonesTest()
    _auxZones = AuxZoneDesc(giveZoneInfo(rand(10:15)))
    auxZones = qccdSimulator.QCCDevControl._initAuxZones(_auxZones)
    @assert length(_auxZones.auxZones) == length(auxZones)
    for _auxZone in _auxZones.auxZones
        auxZone = auxZones[Symbol(_auxZone.id)]
        @assert _auxZone.end0 == string(auxZone.end0)
        @assert _auxZone.end1 == string(auxZone.end1)
        @assert _auxZone.capacity == auxZone.capacity
    end
    return true
end

# ========= END Auxiliary and Gate zones tests =========

# ========= Init functions check tests =========
function checkInitErrorsTest()
    qdd::QCCDevCtrl = giveQccCtrl()
    qccdSimulator.QCCDevControl._checkInitErrors(qdd.junctions,qdd.auxZones,
                                                 qdd.gateZones, qdd.loadingZones)
    return true
end

"""
This function checks the edge cases of __auxCheck.
It repeats the same errors for aux, gate, and loading zones.
"""
function checkInitErrorsTestEdgeCases()
    qdd::QCCDevCtrl = giveQccCtrl()
    
    #Aux zone with 'nothing' in both ends should throw error:
    _qdd = deepcopy(qdd)
    k = rand(keys(_qdd.auxZones))
    _qdd.auxZones[k] = AuxZone(k,_qdd.auxZones[k].capacity,nothing,nothing)
    try
        qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
    catch e
        @assert endswith(e.msg, "Element cannot be isolated")
    end
    _qdd = deepcopy(qdd)

    # Randomly pick aux zones (by keys) and change their end0 or end1 to be nonsense.
    # This should throw error too.
    for k ∈ rand(keys(_qdd.auxZones), min(length(keys(_qdd.auxZones)), rand(1:10)))
        _qdd = deepcopy(qdd)
    
        if !isnothing(_qdd.auxZones[k].end0)
            _qdd.auxZones[k] = AuxZone(k,_qdd.auxZones[k].capacity,:nonsense,_qdd.auxZones[k].end1)
        else
            _qdd.auxZones[k] = AuxZone(k,_qdd.auxZones[k].capacity,_qdd.auxZones[k].end0,:nonsense)
        end
        try
            qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
        catch e
            @assert endswith(e.msg, "is wrong connected.")
        end
    end

    #Gate zone with 'nothing' in both ends should throw error:
    _qdd = deepcopy(qdd)
    k = rand(keys(_qdd.gateZones))
    _qdd.gateZones[k] = GateZone(k,_qdd.gateZones[k].capacity,nothing,nothing)
    try
        qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
    catch e
        @assert endswith(e.msg, "Element cannot be isolated")
    end
    _qdd = deepcopy(qdd)

    # Randomly pick gate zones (by keys) and change their end0 or end1 to be nonsense.
    # This should throw error too.
    for k ∈ rand(keys(_qdd.gateZones), min(length(keys(_qdd.gateZones)), rand(1:10)))
        _qdd = deepcopy(qdd)
    
        if !isnothing(_qdd.gateZones[k].end0)
            _qdd.gateZones[k] = GateZone(k,_qdd.gateZones[k].capacity,:nonsense,_qdd.gateZones[k].end1)
        else
            _qdd.gateZones[k] = GateZone(k,_qdd.gateZones[k].capacity,_qdd.gateZones[k].end0,:nonsense)
        end
        try
            qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
        catch e
            @assert endswith(e.msg, "is wrong connected.")
        end
    end

    #Load zone with 'nothing' in both ends should throw error:
    _qdd = deepcopy(qdd)
    k = rand(keys(_qdd.loadingZones))
    _qdd.loadingZones[k] = LoadingZone(k,nothing,nothing)
    try
        qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
    catch e
        @assert endswith(e.msg, "Element cannot be isolated")
    end
    _qdd = deepcopy(qdd)

    # Randomly pick load zones (by keys) and change their end0 or end1 to be nonsense.
    # This should throw error too.
    for k ∈ rand(keys(_qdd.loadingZones), min(length(keys(_qdd.loadingZones)), rand(1:10)))
        _qdd = deepcopy(qdd)
    
        if !isnothing(_qdd.loadingZones[k].end0)
            _qdd.loadingZones[k] = LoadingZone(k,:nonsense,_qdd.loadingZones[k].end1)
        else
            _qdd.loadingZones[k] = LoadingZone(k,_qdd.gateZones[k].end0,:nonsense)
        end
        try
            qccdSimulator.QCCDevControl._checkInitErrors(_qdd.junctions,_qdd.auxZones,
                                                 _qdd.gateZones, _qdd.loadingZones)
        catch e
            @assert endswith(e.msg, "is wrong connected.")
        end
    end
    return true
end

# ========= END functions check tests =========
