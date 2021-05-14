using qccdSimulator.QCCDevControl_Types
using qccdSimulator.QCCDevDes_Types
using Random
using qccdSimulator.QCCDevControl

"""
Generates n junctions connected to ZoneInfoDesc (auxZones or gateZones).
repJunc: Repeats a junction ID.
wrongJunctType: Gives a wrong junction type to a ZoneInfoDesc.
isolatedJunc: The first junction is not connected to any ZoneInfoDesc.
repJunc: Repeats a zone ID.
"""
function giveZonesJunctions(nJunctions:: Int64, juncTypes:: Array{String};
            repJunc=false, wrongJuncType=false, isolatedJunc=false, repZone=false)::
            Tuple{Array{ZoneInfoDesc},Array{JunctionInfoDesc}}

    zones = ZoneInfoDesc[]
    junctions = JunctionInfoDesc[]
    sId = 0
    skipAuxZone = wrongJuncType
    for i in 1:nJunctions
        repJunc && i > 1 ? push!(junctions, JunctionInfoDesc(string(i-1), juncTypes[i])) : 
        push!(junctions, JunctionInfoDesc(string(i), juncTypes[i]))
        if isolatedJunc
            isolatedJunc = false
            continue
        end
        for j in 1:typesSizes[Symbol(juncTypes[i])]
            if skipAuxZone
                skipAuxZone = false
                continue
            end
            push!(zones, ZoneInfoDesc(string(sId),string(i),string(-1),3))
            if repZone
                repZone = false
                continue
            end
            sId += 1
        end
    end
    return zones, junctions
end

"""
Creates some ZoneInfoDesc objects.
"""
function giveZoneInfo(nZones:: Int64;  invZone=false, giveNothing=false)::Array{ZoneInfoDesc}
    zones = ZoneInfoDesc[]
    for i in 1:nZones
        if invZone
            push!(zones,ZoneInfoDesc(string(i),string(i),string(i),2))
            invZone = false
        elseif giveNothing
            push!(zones,ZoneInfoDesc(string(i),"","",2))
            giveNothing = false
        else
            push!(zones,ZoneInfoDesc(string(i),string(i+1),string(i+2),2))
        end
    end
    return zones
end

""" 
Creates a struct QCCDevDescription based in the file topology.json
"""
function giveQccDes()::QCCDevDescription
    gateZone:: GateZoneDesc = GateZoneDesc(
        [ 
            ZoneInfoDesc("1", "", "4", 2),
            ZoneInfoDesc("2", "4", "5", 2),
            ZoneInfoDesc( "3", "7", "8", 2)
        ]
    )
    auxZone:: AuxZoneDesc = AuxZoneDesc(
        [ 
            ZoneInfoDesc( "4", "1", "2", 2),
            ZoneInfoDesc( "5", "5", "9", 2),
            ZoneInfoDesc( "6", "9", "", 2),
            ZoneInfoDesc( "7", "9", "3", 2)
        ]
    )
    junction:: JunctionDesc = JunctionDesc(
        [
            JunctionInfoDesc( "9", "T")
        ]
    )
    loadZone:: LoadZoneDesc = LoadZoneDesc(
        [ 
            LoadZoneInfoDesc( "8", "3", "")
        ]
    )
    return  QCCDevDescription(gateZone,auxZone,junction,loadZone)
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
"""
Creates a struct GateZoneDesc with repeated Ids
"""
function giveGateZoneDescRepeatedId()::GateZoneDesc
    return GateZoneDesc(
        [ 
            ZoneInfoDesc( "1", "", "4", 2),
            ZoneInfoDesc( "2", "4", "5", 2),
            ZoneInfoDesc( "1", "7", "8", 2)
        ]
    )
end

"""
Creates a struct GateZoneDesc with inexistent connection
"""
function giveGateZoneDescNoConnection()::GateZoneDesc
    return GateZoneDesc(
        [ 
            ZoneInfoDesc( "1", "", "4", 2),
            ZoneInfoDesc( "2", "9999999999", "5", 2),
            ZoneInfoDesc( "3", "7", "8", 2)
        ]
    )
end

"""
Creates a struct TrapDesc with wrong connected shuttle
"""
function giveGateZoneDescWrongConnectedShuttle()::GateZoneDesc
    return GateZoneDesc(
        [ 
            ZoneInfoDesc( "1", "", "4", 2),
            ZoneInfoDesc( "2", "7", "5", 2),
            ZoneInfoDesc( "3", "7", "8", 2)
        ]
    )
end


"""
Creates a struct QCCDevCtrl based in the file giveQccDes()
"""
function giveQccCtrl()::QCCDevCtrl
    qccd::QCCDevDescription = giveQccDes()
    gateZones = Dict{Symbol,GateZone}()
    endId = id -> id == "" ? nothing : Symbol(id)
    map(tr -> gateZones[Symbol(tr.id)] = GateZone(Symbol(tr.id), tr.capacity,
                                endId(tr.end0), endId(tr.end1)
                              , tr.gate, tr.loading_zone), qccd.gateZone.gateZones)
    auxZones = Dict{Symbol,AuxZone}()
    map(sh -> auxZones[Symbol(sh.id)] = AuxZone(Symbol(sh.id), sh.capacity,
                                                endId(sh.end0), endId(sh.end1)),
              qccd.auxZone.auxZones)

    junctions = Dict{Symbol,Junction}()
    for j ∈ qccd.junction.junctions
        connectedShuttles = filter(x -> x.end0 == j.id || x.end1 == j.id, qccd.shuttle.shuttles)
        junctionEnds = Dict(Symbol(s.id) => JunctionEnd() for s ∈ connectedShuttles)
        junctions[Symbol(j.id)] = Junction(Symbol(j.id), Symbol(j.type), junctionEnds)
    end

    return QCCDevCtrl(qccd,:No,false,0,gateZones,junctions,auxZones, graph)
end
