include("darp.jl")
using StaticArrays
using TimerOutputs
using Test

struct OptRoute
    c::Float64
    q::Float64
    d::Float64
    w::Float64
    t::Float64
    function OptRoute(c::Float64, q::Float64, d::Float64, w::Float64, t::Float64)
        return new(c, q, d, w, t)
    end
end

struct OptRoutes
    optRouteDict::Dict{Int64,OptRoute}
    lastMove::Union{Nothing,Tuple{Int64,Int64}}
    otherVal::Float64 # other value in the function excpet cost
    rawCostVal::Float64 # raw cost value (without penality)
    costPenality::Float64 # penality factor
    Val::Float64 # final optimzation function value

    function OptRoutes(optRouteDict::Dict{Int64,OptRoute}, va::VoilationVariables, move::Union{Nothing,Tuple{Int64,Int64}}, moveIncludedInLongMemory::Bool=true)
        c = 0.0
        q = 0.0
        d = 0.0
        w = 0.0
        t = 0.0
        for (k, v) in optRouteDict
            c += v.c
            q += v.q
            d += v.d
            w += v.w
            t += v.t
        end
        otherVal = ((q * va.ALPHA) + (d * va.BETA) + (w * va.GAMMA) + (t * va.TAU))
        rawCostVal = c
        costPenality = 1.0
        if !isnothing(move)
            freqOfMoveUsed = get(va.LongerTermTabuMemory, move, 1)
            if !moveIncludedInLongMemory # sometimes, when we are incrementally calculating things, we dont include it to avoid unnecessary copies
                freqOfMoveUsed = get(va.LongerTermTabuMemory, move, 0) + 1
            end
            costPenality = va.LAMBDA * va.sqrt_nm * freqOfMoveUsed
        end
        Val = (costPenality * rawCostVal) + otherVal
        return new(optRouteDict, move, otherVal, rawCostVal, costPenality, Val)
    end
end

function route_values!(::Val{N}, darp::DARP, route::GenericRoute{N}, to::Union{Nothing,TimerOutput}) where {N}
    RVals{N}
    # dictionary/mapping for index to position in route
    # this is a allocation
    # discard the map

    rmap = Dict{Int64,Int64}(route[1] => 1)
    A = emptyRValue(N) # Arrival
    w = emptyRValue(N) # wait time
    B = emptyRValue(N) # beggening of service
    D = emptyRValue(N) # Departure
    y = emptyRValue(N) # load
    for index in eachindex(route)
        if index <= 1
            continue
        end
        # update routeMaps
        prevNode = route[index-1]
        curNode = route[index]
        if prevNode == darp.end_depot && curNode == 0 # reached end of the route
            break
        end
        rmap[curNode] = index
        prevIndex = rmap[prevNode]
        curIndex = rmap[curNode]

        A[curIndex] = D[prevIndex] + travel_time(darp, prevNode, curNode)
        B[curIndex] = A[curIndex]
        D[curIndex] = B[curIndex] + darp.d[curNode]
        w[curIndex] = B[curIndex] - A[curIndex]
        y[curIndex] = y[prevIndex] + darp.q[curNode]
    end
    return RVals{N}(rmap, A, w, B, D, y)
end

function calc_opt_full(valN::Val{N}, darp::DARP, rvalues::Dict{Int64,RVals{N}}, routes::GenericRoutes{N}, vc::VoilationVariables) where {N}
    OptRoutes
    optRouteDict = Dict{Int64,OptRoute}(k => calc_opt_for_route(valN, darp, routes[k], rvalues[k]) for k in darp.vehicles)
    optRoutes = OptRoutes(optRouteDict, vc, nothing, false)
    return optRoutes
end


function calc_opt_for_route(::Val{N}, darp::DARP, route::GenericRoute{N}, rvals::RVals{N}) where {N}
    OptRoute
    c = 0.0
    q = 0.0
    d = 0.0
    w = 0.0
    t = 0.0

    rmap = rvals.rmap
    end_depot_index = rmap[darp.end_depot]
    duration_of_route = rvals.D[end_depot_index]

    # duration of route
    d += max(duration_of_route - darp.T_route, 0)
    prev = route[1]

    for cur in route[2:end]
        cur_index = rmap[cur]
        # max cap in route
        q = max(rvals.y[cur_index] - darp.Q, 0)
        # cost of travel
        c += travel_time(darp, prev, cur)
        prev = cur
        if cur == darp.end_depot || cur == darp.start_depot || cur <= 0
            continue
        end
        cur_dropoff_index = rmap[-cur]
        Bi_pickup = rvals.B[cur_index]
        Bi_dropoff = rvals.B[cur_dropoff_index]
        _, li_pickup = darp.tw[cur]
        _, li_dropoff = darp.tw[-cur]
        # late_quantity
        w += max(Bi_pickup - li_pickup, 0) + max(Bi_dropoff - li_dropoff, 0)
        # ride time
        t += max(Bi_dropoff - Bi_pickup, 0)
    end

    return OptRoute(c, q, d, w, t)
end

function calc_opt_incr(valN::Val{N}, darp::DARP, routes::Routes{N}, move::MoveParams, optRoutes::OptRoutes, va::VoilationVariables) where {N}
    OptRoutes
    routeK1 = routes[move.k1]
    routeK2 = routes[move.k2]
    # create a copy since we will modify this
    optRouteDict = copy(optRoutes.optRouteDict)

    newRouteK1 = remove_from_route(valN, darp, routeK1, move.i)
    newRouteK2 = insert_to_route(valN, darp, routeK2, move.i, move.p1, move.p2)
    newRvalK1 = route_values!(valN, darp, newRouteK1, nothing)
    newRvalK2 = route_values!(valN, darp, newRouteK2, nothing)
    optRouteDict[move.k1] = calc_opt_for_route(valN, darp, newRouteK1, newRvalK1)
    optRouteDict[move.k2] = calc_opt_for_route(valN, darp, newRouteK2, newRvalK2)
    # make a shallow copy this time
    return OptRoutes(optRouteDict, va, (move.i, move.k2), false) # move is not included yet in long memory
end

# except move to already added to longterm memory
function apply_move(valN::Val{N}, darp::DARP, move::MoveParams, curRoutes::Routes{N}, curRVals::Dict{Int64,RVals{N}}, curOptRoutes::OptRoutes, va::VoilationVariables) where {N}
    newRoutes = Dict{Int64,Route{N}}(k => copy(curRoutes[k]) for k in darp.vehicles)
    newRoutes[move.k1] = remove_from_route(valN, darp, curRoutes[move.k1], move.i)
    newRoutes[move.k2] = insert_to_route(valN, darp, curRoutes[move.k2], move.i, move.p1, move.p2)

    # make a copy since will modify this
    newRVals = Dict{Int64,RVals{N}}(k => RVals{N}(copy(curRVals[k].rmap), curRVals[k].A, curRVals[k].w, curRVals[k].B, curRVals[k].D, curRVals[k].y) for k in darp.vehicles)
    newRVals[move.k1] = route_values!(valN, darp, newRoutes[move.k1], nothing)
    newRVals[move.k2] = route_values!(valN, darp, newRoutes[move.k2], nothing)

    optRouteDict = copy(curOptRoutes.optRouteDict)
    optRouteDict[move.k1] = calc_opt_for_route(valN, darp, newRoutes[move.k1], newRVals[move.k1])
    optRouteDict[move.k2] = calc_opt_for_route(valN, darp, newRoutes[move.k2], newRVals[move.k2])
    return newRoutes, newRVals, OptRoutes(optRouteDict, va, (move.i, move.k2), true)
end

function performIntraRouteOptimimzation(valN::Val{N}, vID::Int64, curRoute::Route{N}, curOptRoutes::OptRoutes,
    darp::DARP, va::VoilationVariables) where {N}

    # take every index and put it in different index
    rvals = route_values!(valN, darp, curRoute, nothing)
    n = rvals.rmap[darp.end_depot]
    optRoute = calc_opt_for_route(valN, darp, curRoute, rvals)

    bestRoute = curRoute
    bestOptRoutes = curOptRoutes
    curOptRouteDict = copy(bestOptRoutes.optRouteDict)

    # goal is to get a value better than this
    bestOptVal = bestOptRoutes.Val

    for iIdx in 1:n-1
        i = curRoute[iIdx]
        if i == darp.start_depot
            continue
        end
        if i == darp.end_depot
            break
        end

        for jIdx in 2:n-1
            j = curRoute[jIdx]
            if j == darp.end_depot
                break
            end
            if abs(i) == abs(j)
                continue
            end

            # put i in place of j and j in place of i
            # if i is pickup node, rmap[-i] > rmap[j]
            if i > 0
                pickupIndx = rvals.rmap[i]
                dropoffIndex = rvals.rmap[-i]
            else
                pickupIndx = rvals.rmap[-i]
                dropoffIndex = rvals.rmap[i]
            end
            if pickupIndx > dropoffIndex
                continue
            end
            newRoute = copy(curRoute)
            newRoute[iIdx], newRoute[jIdx] = newRoute[jIdx], newRoute[iIdx]
            newRvals = route_values!(valN, darp, newRoute, nothing)
            curOptRouteDict[vID] = calc_opt_for_route(valN, darp, newRoute, newRvals)
            newOptRoutes = OptRoutes(curOptRouteDict, va, bestOptRoutes.lastMove, true)

            if newOptRoutes.Val < bestOptRoutes.Val
                bestRoute = newRoute
                bestOptRoutes = newOptRoutes
            end
        end
    end

    return bestRoute
end

