# src/qccdevcontrol.jl
# Created by Anabel Ovide and Alejandro Villoria, 23 April, 2021
# MIT license
# Sub-module QCCDevCtrl

module QCCDev_Feasible
export load_checks, OperationNotAllowedException, isallowed_load, isallowed_swap

using ..QCCDevControl_Types
using ..QCCDevDes_Types

"""
Default error message for QCCD operations.
"""
struct OperationNotAllowedException <: Exception
  msg ::String
end

"Nicer way to throw error"
opError(x) = throw(OperationNotAllowedException(x))

"""
Function `time_check()` — checks if given time is correct

# Arguments
* `qdc:: Time_t` — Actual qdc device's time.
* `t::Time_t` — time at which the operation commences.  Must be no earlier than the latest time
  given to previous function calls.

The function throws an error if time is not correct.
"""
function _time_check(t_qdc:: Time_t, t::Time_t, id::Symbol) 
  0 ≤ t_qdc ≤ t  || opError("Time must be higher than $t_qdc")
  haskey(OperationTimes, id) || opError("Time model for $id not defined.")
end

"""
Function `isallowed_load()` — checks if load operation is posisble

# Arguments
* `qdc::QCCDevControl` — Actual device's status.
* `loading_zone::Symbol` — Desired place to load an ion
* `t::Time_t` — Time at which the operation commences.  Must be no earlier than the latest time
                given to previous function calls.
# checks
* Check time — Call _time_check function.
* Check maximum capacity — Check device's maximum capacity is not exeeded.
* Check trap exist — Check current loading_zone exist.
* Check hole is avialable — Checl loading hole is not busy.
"""
function isallowed_load(qdc::QCCDevControl, loading_zone::Symbol, t::Time_t)
    _time_check(qdc.t_now, t, :load)
    haskey(qdc.loadingZones, loading_zone) || opError("Loading zone with id $loading_zone doesn't exist.")
    qdc.loadingZones[loading_zone].hole != nothing && opError("Loading hole is busy.")
end

"""
Function `isallowed_swap()` — checks if load operation is posisble

# Arguments
* `qdc::QCCDevControl` — Actual device's status.
* `ion𝑖_idx`, 𝑖=1,2, the (1-based) indices of the two ions.  Must be in the same gate zone.
* `t::Time_t` — Time at which the operation commences.  Must be no earlier than the latest time
                given to previous function calls.
# checks
* Check time — Call _time_check function.
* Check if two ions exists
* check if ions are in same chain and are adjacents
* Check if chain is in a gate zone
"""
function isallowed_swap(qdc::QCCDevControl, ion1_idx:: Int, ion2_idx:: Int , t::Time_t)
    _time_check(qdc.t_now, t, :load)
    haskey(qdc.qubits, ion1_idx) || opError("Qubit with id $ion1_idx doesn't exist.")
    haskey(qdc.qubits, ion2_idx) || opError("Qubit with id $ion2_idx doesn't exist.")
    qdc.qubits[ion1_idx].position == qdc.qubits[ion2_idx].position || 
                    opError("Qubits with ids $ion1_idx  and $ion2_idx are not in the same zone.")
    # Pending Alex's code finding zone -> zone
    position = qdc.qubits[ion1_idx].position
    zone.typeZone == :gateZone || opError("Swap can only be done in Gate Zones.")
    pos1 = findall(x->x==ion1_idx, zone.chain)
    pos2 = findall(x->x==ion2_idx, zone.chain)
    pos1 == pos2 + 1 || pos1 == pos2 - 1 || 
                    opError("Qubits with ids $ion1_idx  and $ion2_idx are not adjacents.")
end


end 