include("../utils/testUtils.jl")
include("../../src/qccdParser.jl")

function _initJunctionsTest()
    typeSizes = Dict(T => 3, Y => 3, X => 4)
    shuttles, _junctions = giveShuttlesJunctions(9, ["X", "Y", "T","X", "Y", "T","X", "Y", "T"])
    junctions = _initJunctions(shuttles, _junctions)
    for (k,junction) in junctions
        @assert k == junction.id
        juncType = eval(Meta.parse(filter(x-> x.id==k,_junctions)[1].type))
        @assert junction.type == juncType
        shuttleIds = keys(junction.ends)
        @assert length(shuttleIds) == typeSizes[juncType]
        for shuttleId in shuttleIds
            shuttle = filter(x -> x.id == shuttleId, shuttles)[1]
            @assert shuttle.from == k || shuttle.to == k
        end
    end
    return true
end

function _initJunctionsTestRepId()
    shuttles, _junctions = giveShuttlesJunctions(2, ["T","T"];repJunction = true)
    junctions = _initJunctions(shuttles, _junctions)
end