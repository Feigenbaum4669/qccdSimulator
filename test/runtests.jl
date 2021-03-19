include("qccdDev.jl")
include("../src/qccdParser.jl")
using qccdSimulator
using Test
using LightGraphs

@testset "Graph initialization" begin
    @test_throws ArgumentError("Input is not a file") createDevice(".")
    @test_throws ArgumentError createDevice("./testFiles/wrongTopology.json")
    @test nv(createDevice("./testFiles/topology.json")) == 5
    @test ne(createDevice("./testFiles/topology.json")) == 6
end

@testset "Topology object initialization" begin
    @test _initJunctionsTest()
    @test_throws ArgumentError _initJunctionsTestRepId()
end