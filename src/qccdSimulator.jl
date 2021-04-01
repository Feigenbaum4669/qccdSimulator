module qccdSimulator
export readJSON

include("./types/description.jl")

using .QCCDevDes_Types
using JSON3

"""
Creates an object topologyJSON from JSON.
Throws ArgumentError an error if input is not a valid file.
"""
function readJSON(path::String)::QCCDevDescription
    if !isfile(path)
        throw(ArgumentError("Input is not a file"))
    end
    # Parsing JSON
    return topology::QCCDevDescription  = try 
        JSON3.read(read(path, String), QCCDevDescription)
    catch err
        throw(ArgumentError(err.msg))
    end
end

include("./types/control.jl")
include("./qccdevcontrol.jl")

end
