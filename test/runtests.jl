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
    @test QCCDevCtrlOKTest()
    @test nv(QCCDevCtrlTest().graph) == 5
    @test ne(QCCDevCtrlTest().graph) == 6
    @test initJunctionsTest()
    @test_throws ArgumentError("Repeated junction ID: 1.") initJunctionsTestRepId()
    @test_throws ArgumentError("Junction with ID 1 isolated.") initJunctionsTestIsolated()
    @test_throws ArgumentError("Junction with ID 1 of type T has 2 ends. " * 
                               "It should have 3 ends.") initJunctionsTestWrongType()
    @test_throws ArgumentError initShuttlesTestRepId()
    @test initTrapTest()
    @test_throws ArgumentError("Repeated Trap ID: 1.") initTrapRepeatedIdTest()
    @test checkTrapsTest()
    @test_throws ArgumentError("Shuttle connected to trap ID 2 does not exist or is" * 
                               " wrong connected.") checkTrapsShuttleNotExistTest()
    @test_throws ArgumentError("Shuttle connected to trap ID 1 does not exist or is" * 
    " wrong connected.") checkTrapsShuttleWrongConnectedTest()
end
