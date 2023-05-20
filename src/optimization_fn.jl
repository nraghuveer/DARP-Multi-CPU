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
    feasible::Bool
    endDepotIdx::Int64
    removalWeights::Weights
    insertionWeights::Weights
    function OptRoute(c::Float64, q::Float64, d::Float64, w::Float64, t::Float64, feasible::Bool, endDepotIdx::Int64, removalWeights::Weights, insertionWeights::Weights)
        return new(c, q, d, w, t, feasible, endDepotIdx, removalWeights, insertionWeights)
    end
end

struct OptRoutes
    optRouteDict::Dict{Int64,OptRoute}
    lastMove::Union{Nothing,Tuple{Int64,Int64}}
    otherVal::Float64 # other value in the function excpet cost
    rawCostVal::Float64 # raw cost value (without penality)
    costPenality::Float64 # penality factor
    Val::Float64 # final optimzation function value
    moveIncludedInLongMemory::Bool
    feasible::Bool

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
        Val = (costPenality * rawCostVal) + rawCostVal + otherVal
        feasible = true
        for (k, d) in optRouteDict
            feasible = feasible && d.feasible
        end

        return new(optRouteDict, move, otherVal, rawCostVal, costPenality, Val, moveIncludedInLongMemory, feasible)
    end
end

function route_values!(valN::Val{N}, darp::DARP, route::GenericRoute{N}, to::Union{Nothing,TimerOutput}) where {N}
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
    L = Dict{Int64,Float64}([])
    L[darp.start_depot] = 0
    L[darp.end_depot] = 0
    routeSize::Int64 = length(route)

    # Step 1
    D[1] = darp.tw[route[1]][1] # set D0 = e0
    # Step 2
    for index in eachindex(route)
        if index == 1
            continue
        end
        prevNode = route[index-1]
        curNode = route[index]
        if curNode == 0
            break
        end
        if curNode == darp.end_depot
            routeSize = index
        end

        rmap[curNode] = index
        prevIndex = rmap[prevNode]
        curIndex = rmap[curNode]

        ei, li = darp.tw[curNode]
        travel = travel_time(darp, prevNode, curNode)
        A[curIndex] = D[prevIndex] + travel
        B[curIndex] = max(ei, A[curIndex])
        D[curIndex] = B[curIndex] + darp.d[curNode]
        w[curIndex] = B[curIndex] - A[curIndex]
        y[curIndex] = y[prevIndex] + darp.q[curNode]
    end

    for i in 1:routeSize
        req = route[i]
        if req < 0 || req == darp.start_depot || req == darp.end_depot
            continue
        end
        pIndex = rmap[req]
        dIndex = rmap[-req]
        L[req] = B[dIndex] - D[pIndex]
    end

    # calculate wait time prefix values

    # Step 3
    # computer F0
    F0 = calc_forward_time_slack(valN, 1, route, rmap, routeSize, darp, B, w, L)
    # Step 4
    e0, l0 = darp.tw[route[1]]
    wp_enddepot = calc_waittime_in_range(valN, route, rmap, w, 2, routeSize)
    D[1] = e0 + min(F0, wp_enddepot) # sum of all wait times
    # Step 5
    for i in 2:routeSize
        prevNode = route[i-1]
        curNode = route[i]
        prevIndex = rmap[prevNode]
        curIndex = rmap[curNode]

        ei, li = darp.tw[curNode]
        travel = travel_time(darp, prevNode, curNode)
        A[curIndex] = D[prevIndex] + travel
        B[curIndex] = max(ei, A[curIndex])
        D[curIndex] = B[curIndex] + darp.d[curNode]
        w[curIndex] = B[curIndex] - A[curIndex]
        y[curIndex] = y[prevIndex] + darp.q[curNode]
    end
    # Step 6
    for i in 1:routeSize
        req = route[i]
        if req < 0 || req == darp.end_depot || req == darp.start_depot
            continue
        end
        pIndex = rmap[req]
        dIndex = rmap[-req]
        L[req] = B[dIndex] - D[pIndex]
    end
    # Step 7
    for j in 2:routeSize
        req = route[j]
        if req < 0
            continue
        end
        reqIdx = rmap[req]
        Fi = calc_forward_time_slack(valN, j, route, rmap, routeSize, darp, B, w, L)
        endDepotIdx = rmap[darp.end_depot]
        Wp = calc_waittime_in_range(valN, route, rmap, w, reqIdx + 1, endDepotIdx)
        B[reqIdx] = B[reqIdx] + min(Fi, Wp)
        D[reqIdx] = B[reqIdx] + darp.d[req]
        # Update A,W,B,D
        for i in j+1:routeSize
            prevNode = route[i-1]
            curNode = route[i]
            prevIndex = rmap[prevNode]
            curIndex = rmap[curNode]

            ei, li = darp.tw[curNode]
            travel = travel_time(darp, prevNode, curNode)
            A[curIndex] = D[prevIndex] + travel
            B[curIndex] = max(ei, A[curIndex])
            D[curIndex] = B[curIndex] + darp.d[curNode]
            w[curIndex] = B[curIndex] - A[curIndex]
            y[curIndex] = y[prevIndex] + darp.q[curNode]
        end
        for i in j+1:routeSize
            req = route[i]
            if req >= 0
                continue
            end
            pIndex = rmap[-req]
            dIndex = rmap[req]
            L[req] = B[dIndex] - D[pIndex]
        end
    end

    return RVals{N}(rmap, A, w, B, D, y)
end


function calc_waittime_in_range(::Val{N}, route::GenericRoute{N}, rmap::Dict{Int64,Int64},
    w::MVector{N,Float64}, startAt::Int64, endAt::Int64) where {N}
    if endAt > startAt
        return Inf
    end
    res::Float64 = 0.0
    for i in startAt:endAt
        node = route[i]
        nodeIdx = rmap[node]
        waitTimeAtNode = w[nodeIdx]
        res += waitTimeAtNode
    end
    return res
end

function calc_forward_time_slack(valN::Val{N}, i::Int64, route::GenericRoute{N}, rmap::Dict{Int64,Int64}, routeSize::Int64, darp::DARP, B::MVector{N,Float64}, w::MVector{N,Float64}, L::Dict{Int64,Float64}) where {N}
    Fi = Inf
    for j in i:routeSize
        nodeJ = route[j]
        ej, lj = darp.tw[nodeJ]
        Pj = Inf
        for p in i+1:j
            # waittime from i+1 to j
            Wp = calc_waittime_in_range(valN, route, rmap, w, i + 1, p)
            Pj = Inf
            if nodeJ < 0 # dropOf
                Pj = L[-nodeJ]
            end
            Fi = min(Fi, Wp + max(0.0, min(lj - B[i], darp.T_route - Pj)))
        end
    end
    return Fi
end

function calc_opt_full(valN::Val{N}, darp::DARP, rvalues::Dict{Int64,RVals{N}}, routes::GenericRoutes{N}, vc::VoilationVariables) where {N}
    OptRoutes
    optRouteDict = Dict{Int64,OptRoute}(k => calc_opt_for_route(valN, darp, routes[k], rvalues[k]) for k in darp.vehicles)
    optRoutes = OptRoutes(optRouteDict, vc, nothing, false)
    return optRoutes
end


function calc_opt_for_route(::Val{N}, darp::DARP, route::GenericRoute{N}, rvals::RVals{N}) where {N}
    OptRoute
    c = 0.0 # cost
    q = 0.0 # load
    d = 0.0 # duration
    w = 0.0 # time window
    t = 0.0 # ride time
    feasible = false

    rmap = rvals.rmap
    endIdx = rmap[darp.end_depot]
    startIdx = rmap[darp.start_depot]
    duration_of_route = rvals.D[endIdx] - rvals.D[startIdx]
    # duration voilation
    d += max(duration_of_route - darp.T_route, 0)
    prev = route[1]

    for cur in route[2:end]
        curIdx = rmap[cur]
        if cur == darp.end_depot
            break
        end
        # max cap in route
        q = max(rvals.y[curIdx] - darp.Q, 0)
        # cost of travel
        c += travel_time(darp, prev, cur)
        ei, li = darp.tw[cur]
        w += max(0.0, rvals.B[curIdx] - li)
        if cur > 0
            dropofIdx = rvals.rmap[-cur]
            maxRideTime = darp.requestsDict[cur].max_ride_time
            # ride time for this request
            rideTime = rvals.B[dropofIdx] - rvals.D[curIdx]
            t += max(0.0, maxRideTime - rideTime)
        end

        prev = cur
    end

    # check voilation or constraints
    removalWeightsArr = fill(0.1, endIdx)
    removalWeightsArr[1] = removalWeightsArr[endIdx] = 0.0
    insertionWeightsArr = fill(0.1, endIdx)
    insertionWeightsArr[1] = insertionWeightsArr[endIdx] = 0.0

    feasible = true
    for cur in route
        if cur == darp.start_depot || cur == darp.end_depot
            continue
        end
        ei, li = darp.tw[cur]
        curIdx = rvals.rmap[cur]

        if rvals.B[curIdx] > li
            x = rvals.B[curIdx] - li
            removalWeightsArr[curIdx] = removalWeightsArr[curIdx] * x
        else
            x = li - rvals.B[curIdx]
            insertionWeightsArr[curIdx] = insertionWeightsArr[curIdx] * x
        end
        # Ride time constraint
        if cur > 0
            dIndex = rvals.rmap[-cur]
            pIndex = curIdx
        else
            pIndex = rvals.rmap[-cur]
            dIndex = curIdx
        end
    end

    removalWeights = Weights(removalWeightsArr)
    insertionWeights = Weights(insertionWeightsArr)

    return OptRoute(c, q, d, w, t, feasible, endIdx, removalWeights, insertionWeights)
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

function performIntraRouteOptimimzation(valN::Val{N}, vID::Int64, curRoute::Route{N}, curOptRoutes::OptRoutes, darp::DARP, va::VoilationVariables) where {N}

    # take every index and put it in different index
    rvals = route_values!(valN, darp, curRoute, nothing)
    n = rvals.rmap[darp.end_depot]
    optRoute = calc_opt_for_route(valN, darp, curRoute, rvals)

    bestRoute = curRoute
    bestOptRoutes = curOptRoutes

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
            optRoute = calc_opt_for_route(valN, darp, newRoute, newRvals)
            if !optRoute.feasible
                continue
            end

            # dropin replace and check if value is improving
            newOptRoutes = OptRoutes(Dict{Int64,OptRoute}([(vID, optRoute)]), va, curOptRoutes.lastMove, curOptRoutes.moveIncludedInLongMemory)

            if newOptRoutes.Val < bestOptRoutes.Val
                bestRoute = newRoute
                bestOptRoutes = newOptRoutes
            end
        end
    end

    return bestRoute
end

function printRoutesDetailed(routes::Routes{N}, darp::DARP, optRoutes::OptRoutes) where {N}
    for k in sort(darp.vehicles)
        route = routes[k]
        resultStr = ""
        optRoute = optRoutes.optRouteDict[k]
        for v in route
            ev, lv = darp.tw[v]
            result = "$(v) tw=($(ev), $(lv))| "
            resultStr = resultStr * result
            if v == darp.end_depot
                break
            end
        end

        feasibleStr = "feasible"
        if !optRoute.feasible
            feasibleStr = "not-feasible"
        end

        # println("$(k) $(feasibleStr)")
    end
    # println("#####################################")
end

function generate_random_moves(::Val{N}, ::Val{N_SIZE}, iterationNum::Int64, darp::DARP,
    baseRoutes::Routes{N}, baseOptRoutes::OptRoutes, destMoves::MVector{N_SIZE,MoveParams}, va::VoilationVariables) where {N,N_SIZE}
    Int64, VoilationVariables

    routes::Dict{Int64,Vector{Int64}} = Dict(k => [] for k in darp.vehicles)
    for k in darp.vehicles
        for v in baseRoutes[k]
            push!(routes[k], v)
            if v == darp.end_depot
                break
            end
        end
    end

    vehicles = darp.vehicles
    vehicleWeights = darp.vehicleWeights

    tabuMissCount = 0
    seedRng = MersenneTwister(iterationNum)
    idx = 1
    while idx <= N_SIZE
        k1, k2 = StatsBase.sample(seedRng, vehicles, vehicleWeights, 2, replace=false)
        k1OptRoute = baseOptRoutes.optRouteDict[k1]
        k2OptRoute = baseOptRoutes.optRouteDict[k2]

        # pick a request from k1
        iRes = StatsBase.sample(seedRng, routes[k1], k1OptRoute.removalWeights, 1)
        i = abs(iRes[1])
        if i == darp.start_depot || i == darp.end_depot
            continue
        end

        len_k2::Int64 = length(routes[k2])
        if len_k2 <= 2 # just start and end
            p1, p2 = 2, 3
        else
            p1, p2 = StatsBase.sample(seedRng, 1:len_k2, k2OptRoute.insertionWeights, 2, replace=false, ordered=true)
        end

        param = MoveParams(i, k1, k2, p1, p2, false)
        isTabued, va, _ = va.checkTabuMem(iterationNum, param, va)
        destMoves[idx] = param
        idx += 1
        if !isTabued
            param = MoveParams(i, k1, k2, p1, p2, true)
        end
    end
    return tabuMissCount, va
end


