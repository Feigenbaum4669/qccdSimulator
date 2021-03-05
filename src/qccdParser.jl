using LightGraphs
import JSON

# Input -> Json path
# Output -> topology
# Creates a topology using a definition from JSON
function createTopology(path::String)::SimpleDiGraph{Int64}

    if !isfile(path)
        throw(ArgumentError(path + " Is not a file"))
    end
    # Parsing JSON
    json = JSON.parsefile(path)

    # Initialize graphs
    adjacency = json["adjacency"]
    topology = DiGraph(length(adjacency))

    # Adding nodes
    for nodes in keys(adjacency)
        for node in adjacency[nodes]
            add_edge!(topology, parse(Int64, nodes), parse(Int64, node))
        end
    end
    return topology
end