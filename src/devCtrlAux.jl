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