include("../src/qccdParser.jl")
using qccdSimulator
# using qccdParser
using Test
using LightGraphs

#= 
Check if input is path.
Check number of vertices of graph
Check number of edges =#
@testset "Graph initialization" begin
    @test_throws ArgumentError createTopology(".")
    @test nv(createTopology("./testFiles/topology.json")) == 5
    @test ne(createTopology("./testFiles/topology.json")) == 6
end