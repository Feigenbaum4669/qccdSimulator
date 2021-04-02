include("../utils/testUtils.jl")
using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevControl

function readJSONOK(path::String)
    qccd1 = readJSON(path)
    qccd2 = giveQccDes()
    checkEqualQCCD(qccd1,qccd2)
    return true
end

function checkEqualQCCD(qccd1::QCCDevDescription, qccd2::QCCDevDescription)
    @assert qccd1.adjacency.nodes == qccd2.adjacency.nodes
    traps1 = qccd1.trap.traps
    traps2 = qccd2.trap.traps
    @assert size(traps1) == size(traps2)
    @assert qccd1.trap.capacity == qccd2.trap.capacity
    for (trap1,trap2) in zip(traps1,traps2)
        @assert trap1.id == trap2.id
        @assert trap1.end0 == trap2.end0
        @assert trap1.end1 == trap2.end1
    end
    juns1 = qccd1.junction.junctions
    juns2 = qccd2.junction.junctions
    @assert size(juns1) == size(juns2)
    for (jun1,jun2) in zip(juns1,juns2)
        @assert jun1.id == jun2.id
        @assert jun1.type == jun2.type
    end
    shs1 = qccd1.shuttle.shuttles
    shs2 = qccd2.shuttle.shuttles
    @assert size(shs1) == size(shs2)
    for (sh1,sh2) in zip(shs1,shs2)
        @assert sh1.id == sh2.id
        @assert sh1.from == sh2.from
        @assert sh1.to == sh2.to
    end
end

function _initJunctionsTest()
    _typeSizes = Dict(:T => 3, :Y => 3, :X => 4)
    shuttles, _junctions = giveShuttlesJunctions(9, ["X", "Y", "T","X", "Y", "T","X", "Y", "T"])
    junctions = qccdSimulator.QCCDevControl.initJunctions(shuttles, _junctions)
    for (k,junction) in junctions
        @assert k == junction.id
        juncType = Symbol(filter(x-> x.id==k,_junctions)[1].type)
        @assert junction.type == juncType
        shuttleIds = keys(junction.ends)
        @assert length(shuttleIds) == _typeSizes[juncType]
        for shuttleId in shuttleIds
            shuttle = filter(x -> x.id == shuttleId, shuttles)[1]
            @assert shuttle.from == k || shuttle.to == k
        end
    end
    return true
end

function _initJunctionsTestRepId()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];repJunc = true)
    junctions = qccdSimulator.QCCDevControl.initJunctions(shuttles, _junctions)
end

function _initJunctionsTestIsolated()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];isolatedJunc = true)
    junctions = qccdSimulator.QCCDevControl.initJunctions(shuttles, _junctions)
end

function _initJunctionsTestWrongType()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];wrongJuncType = true)
    junctions = qccdSimulator.QCCDevControl.initJunctions(shuttles, _junctions)
end 

function QCCDevCtrlTest()
    qdd::QCCDevDescription = readJSON("./testFiles/topology.json")
    return QCCDevCtrl(qdd; simulate=false)
end
