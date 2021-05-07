include("tests/qccdDev.jl")
using qccdSimulator
using Test
using LightGraphs

@testset "Read JSON" begin
    @test readJSONOK("./testFiles/topology.json")
    @test_throws ArgumentError("Input is not a file") readJSON(".")
    @test_throws ArgumentError readJSON("./testFiles/wrongTopology.json")
    @test readTimeJSONOK("./testFiles/times.json")
    @test readTimeJSONfail(["./testFiles/negativeTimes.json",
                                        "testFiles/wrongTimes.json","testFiles/wrongTimes2.json"])
    @test readTimeJSONnoFile()
end

@testset "QCCDevCtrl initialization" begin
    @test QCCDevCtrlOKTest()
    # @test nv(QCCDevCtrlTest().graph) == 5
    # @test ne(QCCDevCtrlTest().graph) == 6
    @test initJunctionsTest()
    @test_throws ArgumentError("Repeated junction ID: 1.") initJunctionsTestRepId()
    @test_throws ArgumentError("Junction with ID 1 isolated.") initJunctionsTestIsolated()
    @test_throws ArgumentError("Junction with ID 1 of type T has 2 ends. " * 
                               "It should have 3 ends.") initJunctionsTestWrongType()
    @test_throws ArgumentError initAuxZonesTestRepId()
    @test_throws ArgumentError initAuxZonesTestInvAuxZone()
    @test initAuxZonesTest()
    @test checkAuxZonesTest()
    @test checkAuxZonesTestMissingAdj()
    @test checkAuxZonesTestMissingAuxZone()
    @test checkAuxZonesTestModifyConnections()
    @test initGateZoneTest()
    @test_throws ArgumentError("Repeated Trap ID: 1.") initGateZoneRepeatedIdTest()
    @test checkGateZonesTest()
    @test_throws ArgumentError("Zone connected to gate zone ID 2 does not exist or is" * 
                               " wrong connected.") checkTrapsAuxZoneNotExistTest()
    @test_throws ArgumentError("Zoone connected to gate zone ID 1 does not exist or is" * 
    " wrong connected.") checkGateZonesWrongConnectedTest()
end
