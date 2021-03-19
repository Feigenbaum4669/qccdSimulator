include("../src/qccdParser.jl")
using qccdSimulator
using Test
using LightGraphs

#= 
Check if input is path.
Check if JSON is not the desired one an error is raised
Check number of vertices of graph
Check number of edges 
=#
@testset "Graph initialization" begin
    @test_throws ArgumentError("Input is not a file") createDevice(".")
    @test_throws ArgumentError createDevice("./testFiles/wrongTopology.json")
    @test nv(createDevice("./testFiles/topology.json")) == 5
    @test ne(createDevice("./testFiles/topology.json")) == 6
end
