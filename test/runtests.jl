include("tests/qccdDev.jl")
using qccdSimulator
using Test
using LightGraphs

@testset "Read JSON" begin
    @test readJSONOK("./testFiles/topology.json")
    @test_throws ArgumentError("Input is not a file") readJSON(".")
    @test_throws ArgumentError readJSON("./testFiles/wrongTopology.json")
end

@testset "QCCDevCtrl object initialization" begin
    @test nv(QCCDevCtrlTest().graph) == 5
    @test ne(QCCDevCtrlTest().graph) == 6
    @test initJunctionsTest()
    @test_throws ArgumentError initJunctionsTestRepId()
    @test_throws ArgumentError initJunctionsTestIsolated()
    @test_throws ArgumentError initJunctionsTestWrongType()
    @test_throws ArgumentError initShuttlesTestRepId()
end
