using LightGraphs
using GraphPlot
using Compose
import JSON
import Cairo, Fontconfig

# Input -> Json path
# Output -> Topology
# Creates a topology using a graph from JSON
function createTopology(path::String) :: SimpleDiGraph{Int64}
    # Parsing JSON
    json = JSON.parsefile(path)

    # Initialize graphs
    adjacency = json["adjacency"]
    topology = DiGraph(length(adjacency))

    # Adding nodes
    for nodes in keys(adjacency) 
        for node in adjacency[nodes]
            add_edge!(topology, parse(Int64, nodes) , parse(Int64, node))
        end
    end
    return topology
end

# Check OK
graph = createTopology("../docs/topology.json")
draw(PNG("mygraph.png", 8cm, 8cm), gplot(graph, nodelabel=1:5))
x=enumerate_paths(dijkstra_shortest_paths(graph, 2), 5)
println(typeof(graph))
println(x)