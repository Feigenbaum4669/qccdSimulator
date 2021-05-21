# src/qccdevctrlutils.jl
# Created by Alejandro Villoria and Anabel Ovide, 21 May, 2021
# MIT license
# Sub-module QCCDevCtrl

module QCCDev_Utils

export giveZone

using ..QCCDevControl_Types

"""
Given a zone ID, return the zone from the QCCDevControl object.
Returns `nothing` if no zone with that ID is found.
"""
function giveZone(qdc ::QCCDevControl, id ::Symbol)
    zone = get(qdc.gateZones, id, nothing)
    if isnothing(zone)
        zone = get(qdc.junctions, id, nothing)
    end
    if isnothing(zone)
        zone = get(qdc.auxZones, id, nothing)
    end
    if isnothing(zone)
        zone = get(qdc.loadingZones, id, nothing)
    end
    return zone
end

end # Module