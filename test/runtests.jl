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

@testset "QCCDevControl initialization" begin
    @test QCCDevCtrlOKTest()
    # @test nv(QCCDevCtrlTest().graph) == 5
    # @test ne(QCCDevCtrlTest().graph) == 6
    @test initJunctionsTest()
    @test initJunctionsTestRepId()
    @test initJunctionsTestIsolated()
    @test initJunctionsTestWrongType()
    @test initAuxGateZonesTestRepId()
    @test initAuxGateZonesTestInvZone()
    @test initAuxGateZonesTestWithNothing()
    @test initAuxZonesTest()
    @test initGateZoneTest()
    @test_throws ArgumentError("Repeated gate zone with ID: 1.") initGateZoneRepeatedIdTest()   
    @test initLoadingZoneTest()
    @test_throws ArgumentError("Repeated loading zone with ID: 1") initLoadingZoneRepeatedIdTest()
    @test checkInitErrorsTest()
end
