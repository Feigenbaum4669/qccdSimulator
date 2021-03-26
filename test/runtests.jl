include("tests/qccdDev.jl")
include("../src/qccdParser.jl")
using qccdSimulator
using Test
using LightGraphs

@testset "Read JSON" begin
    @test_throws ArgumentError("Input is not a file") readJSON(".")
    @test_throws ArgumentError readJSON("./testFiles/wrongTopology.json")
end

@testset "QCCDevCtrl object initialization" begin
    @test nv(QCCDevCtrl("./testFiles/topology.json").graph) == 5
    @test ne(QCCDevCtrl("./testFiles/topology.json").graph) == 6
    @test initJunctionsTest()
    @test_throws ArgumentError _initJunctionsTestRepId()
    @test_throws ArgumentError _initJunctionsTestIsolated()
    @test_throws ArgumentError _initJunctionsTestWrongType()
end