using LightGraphs
using GraphPlot
using Compose
import JSON
import Cairo, Fontconfig

# Parsing JSON
j = JSON.parsefile("json.json")

# Initialize graph
adjacency = j["adjacency"]
graph = DiGraph(length(adjacency))

# Adding nodes
for nodes in keys(adjacency) 
    for node in adjacency[nodes]
        add_edge!(graph, parse(Int64, nodes) , parse(Int64, node))
    end
end

# Check OK
draw(PNG("mygraph.png", 8cm, 8cm), gplot(graph, nodelabel=1:5))
x=enumerate_paths(dijkstra_shortest_paths(graph, 2), 5)
println(x)