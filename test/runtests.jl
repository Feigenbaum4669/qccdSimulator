include("qccdDev.jl")
include("../src/qccdParser.jl")
using qccdSimulator
using Test
using LightGraphs

@testset "Graph initialization" begin
    @test_throws ArgumentError("Input is not a file") createTopology(".")
    @test_throws ArgumentError createTopology("./testFiles/wrongTopology.json")
    @test nv(createTopology("./testFiles/topology.json")) == 5
    @test ne(createTopology("./testFiles/topology.json")) == 6
end

@testset "Topology object initialization" begin
    @test _initJunctionsTest()
    @test_throws ArgumentError _initJunctionsTestRepId()
end