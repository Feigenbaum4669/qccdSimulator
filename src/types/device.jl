include("json.jl")

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
    ends: Dict with key being the shuttle ID the junction is connected to and value a JunctionEnd
    @Throws ArgumentError if junction type doesn't match with number of ends. =#
struct Junction
    id::Int64 
    type::JunctionType
    ends::Dict{String,JunctionEnd}
    function Junction(id::Int64, type::JunctionType, ends::Dict{String,JunctionEnd})
        if length(ends) != typesSizes[type]
            throw(ArgumentError(string("Junction with ID ", id, " of type ",type, " has ",length(ends),
            " ends. It should have ", typesSizes[type], " ends.")))
        end
        return new(id, type, ends)
    end
end