@enum QubitStatus begin
    moving
    resting
    waitingDecongestion
    gateApplied
end

@enum JunctionEndStatus begin 
    free
    blocked
end
@enum JunctionType begin 
    T 
    Y
    X 
end

# Supported junction types with corresponding sizes
const typesSizes = Dict(T => 3, Y => 3, X => 4)

"""
Struct for junction end.
queue: Array of qubits waiting in the junction end (if any) 
status: Status of the junction end, either free (queue is empty) or blocked otherwise
"""
struct JunctionEnd
    queue::Array{String,1}
    status::JunctionEndStatus
    JunctionEnd() = new([], free)
    JunctionEnd(queue, status) = new(queue, status)
end

"""
Struct for junction.
id: Junction ID.
type: Type of the junction. Each type may define how the junction works differently
ends: Dict with key being the shuttle ID the junction is connected to and value a JunctionEnd
Throws ArgumentError if junction type doesn't match with number of ends.
"""
struct Junction
    id::Int64 
    type::JunctionType
    ends::Dict{String,JunctionEnd}
    function Junction(id::Int64, type::JunctionType, ends::Dict{String,JunctionEnd})
        if length(ends) != typesSizes[type]
            throw(ArgumentError("Junction with ID "* id* " of type "* type* " has "
            * length(ends)* " ends. It should have "* typesSizes[type]* " ends."))
        end
        return new(id, type, ends)
    end
end

"""  
Struct for the qubits.
id: qubit identifictor 
status: current qubit status
    - moving
    - resting
    - waitingDecongestion
    - gateApplied
position: current qubit position
destination: qubit destination, it could not have any
"""
struct Qubit
    id::String
    status::QubitStatus
    position::Union{String,Int64}
    destination::Union{Nothing,Int64}
end

"""  
Struct for the shuttles.
id: shuttle identifictor 
from & to: direcction of shuttle and endings
Throws ArgumentError if 'from' adn 'to' are the same
"""
struct Shuttle
    id::String
    from::Int64
    to::Int64
    Shuttle(id, from, to) = from == to ?  
            throw(ArgumentError("\"from\" and \"to\" must be different")) : 
            new(id, from, to)
end

"""  
Struct for the trap endings.
qubit: qubit id in that ending 
shuttle: shuttle id the ending is connected
"""
struct TrapEnd
    qubit::String
    shuttle::String
end

"""  
Struct for the traps.
id: trap identifier
capacity: maximum qubits in the trap 
chain: Orderer Qbits in the trap (from end0 to end1)
end0 & end1: Trap endings
Throws ArgumentError if length(chain) > capacity
"""
struct Trap
    id::Int64
    capacity::Int64
    chain::Array{String}
    end0::TrapEnd
    end1::TrapEnd
    Trap(id, capacity, chain, end0, end1) = capacity < length(chain) ? 
        throw(ArgumentError("Trap with id \"$id\" exceeds its capacity")) : 
        new(id, capacity, chain, end0, end1)
end
