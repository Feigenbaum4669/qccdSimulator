using StructTypes

struct TrapEnd
    qubit:: String
    shuttle:: String
end

struct TrapInfo
    id:: Int64
    chain:: Array{String}
    end0:: TrapEnd
    end1:: TrapEnd
    extraAttribute:: String
end

struct Trap
    capacity:: Int64
    traps:: Array{TrapInfo}
    extraAttribute:: String
end

struct JunctionInfo
    id:: Int64
    type:: String
end

struct Junction
    junctions :: Array{JunctionInfo}
    extraAttribute:: String
end

struct  ShuttleInfo
    id:: String
    from:: Int64
    to:: Int64
    extraAttribute:: String
end

struct Shuttle
    shuttles:: Array{ShuttleInfo}
    extraAttribute:: String
end

struct Adjacency
    nodes:: Dict{String,Array{Int64}} 
end

struct Topology
    adjacency:: Adjacency
    trap:: Trap
    junction:: Junction
    shuttle:: Shuttle
end

StructTypes.StructType(::Type{TrapEnd})= StructTypes.Struct()
StructTypes.StructType(::Type{TrapInfo})= StructTypes.Struct()
StructTypes.StructType(::Type{Trap})= StructTypes.Struct()
StructTypes.StructType(::Type{JunctionInfo})= StructTypes.Struct()
StructTypes.StructType(::Type{Junction})= StructTypes.Struct()
StructTypes.StructType(::Type{ShuttleInfo})= StructTypes.Struct()
StructTypes.StructType(::Type{Shuttle})= StructTypes.Struct()
StructTypes.StructType(::Type{Adjacency})= StructTypes.Struct()
StructTypes.StructType(::Type{Topology})= StructTypes.Struct()
