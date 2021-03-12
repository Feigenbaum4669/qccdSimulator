include("json.jl")

@enum JunctionEndStatus free blocked 
@enum JunctionType t x y

#=  Struct for junction end.
    queue: Array of qubits waiting in the junction end (if any) 
    status: Status of the junction end, either free (queue is empty) or blocked otherwise =#
struct JunctionEnd
    queue::Array{String,1}
    status::JunctionEndStatus
    JunctionEnd() = new([], free)
    JunctionEnd(queue, status) = new(queue, status)
end

#=  Struct for junction.
    id: Junction ID.
    type: Type of the junction. Each type may define how the junction works differently
    ends: Dict with key being the shuttle ID the junction is connected to and value a JunctionEnd =#
struct Junction
    id::Int64 
    type::JunctionType
    ends::Dict{Int64,JunctionEnd}
    function Junction(junctionJSON::JunctionJSON)
        
    end
end