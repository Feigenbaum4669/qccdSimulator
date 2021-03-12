using LightGraphs
import JSON3
include("./types/typesJson.jl")

#=  
    Input -> Json path
    Output -> Topology
    Creates a topology using a graph from JSON 
=#
function createTopology(path::String)::SimpleDiGraph{Int64}
    topology::TopologyJSON  = try 
        _readJSON(path::String)
    catch err
        throw(err)
    end
    
    return _createGraph(topology)
end

#=  
    Input -> Json path
    Output -> TopologyJSON
    Creates an object topologyJSON from JSON 
=#
function _readJSON(path::String)::TopologyJSON
    if !isfile(path)
        throw(ArgumentError("Input is not a file"))
    end
    # Parsing JSON
    topology::TopologyJSON  = try 
        JSON3.read(read(path, String), TopologyJSON)
    catch err
        throw(ArgumentError(err.msg))
    end
end

#=  
    Input -> topologyJSON
    Output -> graph
    Creates a graph using a object topologyJSON
=#
function _createGraph(topology::TopologyJSON)::SimpleDiGraph{Int64}
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

