include("../src/qccdParser.jl")
using qccdSimulator
using Test
using LightGraphs

#= 
Check if input is path.
Check number of vertices of graph
Check number of edges =#
@testset "Graph initialization" begin
    @test_throws ArgumentError("Input is not a file") createTopology(".")
    @test nv(createTopology("./testFiles/topology.json")) == 5
    @test ne(createTopology("./testFiles/topology.json")) == 6
end