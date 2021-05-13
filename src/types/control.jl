module QCCDevControl_Types
export GateZone, Junction, AuxZone, Qubit, LoadingZone, QubitStatus, typesSizes, JunctionType

using LightGraphs

# Possible Qubits Status
const QubitStatus = Set([:inLoadingZone, :inGateZone])

# Supported junction types with corresponding sizes
const JunctionType = Set([:T, :Y, :X ])
const typesSizes = Dict(:T => 3, :Y => 3, :X => 4)

"""
Struct for junction.
id: Junction ID.
type: Type of the junction. Each type may define how the junction works differently
ends: Array os its connections Id's
Throws ArgumentError if junction type doesn't match with number of ends.
"""
struct Junction
    id::Symbol 
    type::Symbol
    ends::Array{Symbol}
    function Junction(id::Symbol, type::Symbol, ends::Array{Symbol})
        type in JunctionType || throw(ArgumentError("Junction type $type not supported"))
        if length(ends) != typesSizes[type]
            throw(ArgumentError("Junction with ID $id of type $type has $(length(ends)) ends." *
            " It should have $(typesSizes[type]) ends."))
        end
        return new(id, type, ends)
    end
end

"""  
Struct for the qubits.
id: qubit ID 
status: current qubit status
    - moving
    - resting
    - waitingDecongestion
    - gateApplied
position: current qubit position
destination: qubit destination, it could not have any
"""
struct Qubit
    id::Int
    status::Symbol
    position::Symbol
    destination::Union{Nothing,Symbol}
    function Qubit(id::Int, status::Symbol, position::Symbol,
                                            destination::Union{Nothing,Symbol})
        status in QubitStatus || throw(ArgumentError("Qubit status $status not supported"))
        return new(id, status, position, destination)
    end
end

"""  
Struct for the auxiliary zones.
id: trap identifier
capacity: maximum qubits in the trap 
chain: Ordered Qubits in the trap (from end0 to end1)
end0 & end1: Trap endings
"""
struct LoadingZone
    id::Symbol
    end0::Union{Symbol, Nothing}
    end1::Union{Symbol, Nothing}
    hole::Union{Int, Nothing}
    LoadingZone(id, end0, end1) = new(id, end0, end1, nothing)
end

"""  
Struct for the auxiliary zones.
id: trap identifier
capacity: maximum qubits in the trap 
chain: Ordered Qubits in the trap (from end0 to end1)
end0 & end1: Trap endings
"""
struct AuxZone
    id::Symbol
    capacity::Int64 
    end0::Union{Symbol, Nothing}
    end1::Union{Symbol, Nothing}
    chain::Array{Array{Int64,1},1}
    AuxZone(id, capacity, end0, end1) = new(id, capacity, end0, end1, [[]])
end


"""  
Struct for the gate zones.
id: trap identifier
capacity: maximum qubits in the trap 
chain: Ordered Qubits in the trap (from end0 to end1)
end0 & end1: Trap endings
"""
struct GateZone
    id::Symbol
    capacity::Int64 
    end0::Union{Symbol, Nothing}
    end1::Union{Symbol, Nothing}
    chain::Array{Array{Int64,1},1}
    GateZone(id, capacity, end0, end1) = new(id, capacity, end0, end1, [[]])
end

end