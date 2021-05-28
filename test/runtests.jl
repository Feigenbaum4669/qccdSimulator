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
    @test checkInitErrorsTestEdgeCases()
end

@testset "Linear transport" begin
    @test isallowedLinearTransportTestTime()
    @test isallowedLinearTransportTestNoIon()
    @test isallowedLinearTransportTestNoZone()
    @test isallowedLinearTransportTestNonAdjacent()
    @test isallowedLinearTransportTestAllGood()
    @test isallowedLinearTransportTestFull()
    @test isallowedLinearTransportTestBlockedEnd0()
    @test isallowedLinearTransportTestBlockedEnd1()
    @test isallowedLinearTransportTestNotBlockedEnd0()
    @test isallowedLinearTransportTestNotBlockedEnd1()
end

@testset "Utils" begin
    @test giveZoneTest() 
end

@testset "Time checks" begin
    @test_throws OperationNotAllowedException("Time must be higher than " *
                        "10") time_check_timeFailsTest()
    @test_throws OperationNotAllowedException("Time model for test not " *
                        "defined.") time_check_modelFailsTest()
    @test time_checkOKTest()
end

# TODO: TIMES!
@testset "Load ions `load()` & `isallowed_load()` & `initQubit()`" begin
    @test initQubitTest()
    @test isallowedLoad_OK()
    @test_throws OperationNotAllowedException("Loading zone with id test doesn't" *
                                    " exist.") isallowedLoad_zoneNotExistTest()
    @test_throws OperationNotAllowedException("Loading hole is " *
                                              "busy.") isallowedLoad_loadingHoleBusyTest()
    @test loadOKTest()
end 
