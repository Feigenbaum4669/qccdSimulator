module QCCDevDes_Types
export QCCDevDescription, ZoneInfoDesc, GateZoneDesc, JunctionInfoDesc, JunctionDesc
export AuxZoneDesc, LoadZoneInfoDesc, LoadZoneDesc, OperationTimes, setOperationTimes

using StructTypes

OperationTimes = Dict{Symbol, Int64}()
"""Setter for OperationTimes"""
setOperationTimes(times :: Dict{Symbol, Int64}) = global OperationTimes = times

struct ZoneInfoDesc
    id:: String
    end0:: String
    end1:: String
    capacity:: Int64
end


struct GateZoneDesc
    gateZones:: Array{ZoneInfoDesc}
end


struct JunctionInfoDesc
    id:: String
    type:: String
end
struct JunctionDesc
    junctions :: Array{JunctionInfoDesc}
end


struct AuxZoneDesc
    auxZones:: Array{ZoneInfoDesc}
end


struct LoadZoneInfoDesc
    id:: String
    end0:: String
    end1:: String
end
struct LoadZoneDesc
    loadZones:: Array{LoadZoneInfoDesc}
end


struct QCCDevDescription
    gateZone:: GateZoneDesc
    auxZone:: AuxZoneDesc
    junction:: JunctionDesc
    loadZone:: LoadZoneDesc

end

StructTypes.StructType(::Type{ZoneInfoDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{GateZoneDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{JunctionInfoDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{JunctionDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{AuxZoneDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{LoadZoneInfoDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{LoadZoneDesc})= StructTypes.Struct()
StructTypes.StructType(::Type{QCCDevDescription})= StructTypes.Struct()

end