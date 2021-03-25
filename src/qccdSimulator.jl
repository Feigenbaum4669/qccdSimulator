module qccdSimulator
include("./types/QCCDevDescription.jl")

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
        JSON3.read(read(path, String), TopologyJSON)
    catch err
        throw(ArgumentError(err.msg))
    end
end

export readJSON
end
