using LightGraphs
import JSON3
include("types.jl")

# Input -> Json path
# Output -> Topology
# Creates a topology using a graph from JSON
function createTopology(path::String)::SimpleDiGraph{Int64}
    if !isfile(path)
        throw(ArgumentError(path + " Is not a file"))
    end
    # Parsing JSON
    topology = JSON3.read(read(path, String), Topology)

    # Initialize graphs
    nodesAdjacency = topology.adjacency.nodes
    topology = DiGraph(length(nodesAdjacency))

    # Adding nodes
    for nodes in keys(nodesAdjacency) 
        for node in nodesAdjacency[nodes]
            add_edge!(topology, parse(Int64, nodes), node)
        end
    end
    return topology
end
