using StructTypes

struct TrapEndJSON
    qubit:: String
    shuttle:: String
end

struct TrapInfoJSON
    id:: Int64
    chain:: Array{String}
    end0:: TrapEndJSON
    end1:: TrapEndJSON
end

struct TrapJSON
    capacity:: Int64
    traps:: Array{TrapInfoJSON}
end

struct JunctionInfoJSON
    id:: Int64
    type:: String
end

struct JunctionJSON
    junctions :: Array{JunctionInfoJSON}
end

struct  ShuttleInfoJSON
    id:: String
    from:: Int64
    to:: Int64
end

struct ShuttleJSON
    shuttles:: Array{ShuttleInfoJSON}
end

struct AdjacencyJSON
    nodes:: Dict{String,Array{Int64}} 
end

struct TopologyJSON
    adjacency:: AdjacencyJSON
    trap:: TrapJSON
    junction:: JunctionJSON
    shuttle:: ShuttleJSON
end

StructTypes.StructType(::Type{TrapEndJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{TrapInfoJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{TrapJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{JunctionInfoJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{JunctionJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{ShuttleInfoJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{ShuttleJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{AdjacencyJSON})= StructTypes.Struct()
StructTypes.StructType(::Type{TopologyJSON})= StructTypes.Struct()
