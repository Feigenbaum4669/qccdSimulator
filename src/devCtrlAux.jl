# src/devCtrlAux.jl
# Created by Alejandro Villoria and Anabel Ovide, June 3, 2021
# MIT license
# Auxiliary functions for sub-module QCCDDevControl

using .QCCDevControl_Types

"""
Helper function for `linear_transport()`.
Removes the ion from the origin chain, adds it to the destination chain,
and sets `destination` to `nothing` if it has arrived to its final destination.
# Arguments
* `ion` - Ion to be moved.
* `origin` - Current zone the ion is in.
* `destination` - Zone the ion is going to.
"""
function _move_ion(ion ::Qubit,
    origin ::Union{GateZone, AuxZone, LoadingZone},
    destination ::Union{GateZone, AuxZone, LoadingZone})

  # Remove ion from origin
  if origin.zoneType === :loadingZone
    origin.hole = nothing
  else
    index = origin.end0 === destination.id ? 1 : length(origin.chain)
    deleteat!(origin.chain, index)
  end

  # Add ion to destination and change its position
  if destination.zoneType === :loadingZone
    destination.hole = ion.id
  else
    destination.end0 === origin.id ? pushfirst!(destination.chain, [ion.id]) : 
                                    push!(destination.chain, [ion.id])
  end
  ion.position = destination.id

  # Remove destination to ion if it has arrived to its destination
  if ion.destination === destination.id 
    ion.destination = nothing
  end
end

"""
Helper function for `swap()`.
Swaps the ions in the chain.
# Arguments
* `qdc` - Control device struct.
* `ion1_idx` - First ion to be swaped.
* `ion2_idx` - Second ion to be swaped.
"""
function _swap_ions(qdc::QCCDevControl, ion1_idx:: Int, ion2_idx:: Int)
  zone = giveZone(qdc, qdc.qubits[ion1_idx].position)
  pos1 = nothing
  pos = 0
  for (num,i) in enumerate(zone.chain)
    pos1 = findall(x->x==ion1_idx, i)
    if !isempty(pos1)
      pos = num
      pos1 = pos1[1]
      break
    end
  end
  pos2 = collect(Iterators.flatten(map( y -> findall(x->x==ion2_idx, y), zone.chain)))[1]
  zone.chain[pos][pos1] = ion2_idx
  zone.chain[pos][pos2] = ion1_idx
end

"""
Helper function to compute the time and actualize time in the control device.
# Arguments
* `qdc` - Control device struct.
* `t::Time_t` — time at which the operation commences.
* `op_t::Time_t` — time the opration last.
Returns the actual time after the operation.
"""
function compute_time(qdc::QCCDevControl, t::Time_t, op_t::Time_t)
  t₀ = t + op_t
  t₀ > t  || throw(Error("Error while computing time"))
  qdc.t_now = t₀
  return t₀
end