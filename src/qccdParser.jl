using LightGraphs
import JSON3
include("types.jl")

# Input -> Json path
# Output -> Topology
# Creates a topology using a graph from JSON
function createTopology(path::String)::SimpleDiGraph{Int64}
    if !isfile(path)
        throw(ArgumentError("Input is not a file"))
    end
    
    # Parsing JSON
    topology::Topology  = try 
        JSON3.read(read(path, String), Topology)
    catch err
        throw(ArgumentError(err.msg))
    end
    # Initialize graphs
    nodesAdjacency::Dict{String,Array{Int64}} = topology.adjacency.nodes
    graphTopology::SimpleDiGraph{Int64} = DiGraph(length(nodesAdjacency))

    # Adding nodes
    for nodes in keys(nodesAdjacency) 
        for node in nodesAdjacency[nodes]
            add_edge!(graphTopology, parse(Int64, nodes), node)
        end
    end
    return graphTopology
end
