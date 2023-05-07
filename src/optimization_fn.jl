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
    Val::Float64
    function OptRoutes(darp::DARP, roptVals::Dict{Int64,OptRoute})
        c = 0.0
        q = 0.0
        d = 0.0
        w = 0.0
        t = 0.0
        for k in darp.vehicles
            c += roptVals[k].c
            q += roptVals[k].q
            d += roptVals[k].d
            w += roptVals[k].w
            t += roptVals[k].t
        end
        Val = (c + q + d + w + t) / 1.0
        return new(roptVals, Val)
    end
end

function copyOptRoutes(darp::DARP, optRoutes::OptRoutes)
    OptRoutes
    return OptRoutes(darp, copy(optRoutes.optRouteDict))
end

function reCalOptRoutes(darp::DARP, optRoutes::OptRoutes)
    return OptRoutes(darp, optRoutes.optRouteDict)
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

function calc_opt_full(valN::Val{N}, darp::DARP, rvalues::Dict{Int64,RVals{N}}, routes::GenericRoutes{N}) where {N}
    OptRoutes
    optRouteDict = Dict{Int64,OptRoute}(k => calc_opt_for_route(valN, darp, routes[k], rvalues[k]) for k in darp.vehicles)
    optRoutes = OptRoutes(darp, optRouteDict)
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
        c -= travel_time(darp, cur, -cur)
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

function calc_opt_incr(valN::Val{N}, darp::DARP, routes::Routes{N}, move::MoveParams, optRoutes::OptRoutes) where {N}
    OptRoutes
    routeK1 = routes[move.k1]
    routeK2 = routes[move.k2]
    newOptRoutes::OptRoutes = copyOptRoutes(darp, optRoutes)
    newRouteK1 = remove_from_route(valN, darp, routeK1, move.i)
    newRouteK2 = insert_to_route(valN, darp, routeK2, move.i, move.p1, move.p2)
    newRvalK1 = route_values!(valN, darp, newRouteK1, nothing)
    newRvalK2 = route_values!(valN, darp, newRouteK2, nothing)
    newOptRoutes.optRouteDict[move.k1] = calc_opt_for_route(valN, darp, newRouteK1, newRvalK1)
    newOptRoutes.optRouteDict[move.k2] = calc_opt_for_route(valN, darp, newRouteK2, newRvalK2)
    return reCalOptRoutes(darp, newOptRoutes)
end

function apply_move(valN::Val{N}, darp::DARP, move::MoveParams, curRoutes::Routes{N}, curRVals::Dict{Int64,RVals{N}}, curOptRoutes::OptRoutes) where {N}
    newRoutes = Dict{Int64,Route{N}}(k => copy(curRoutes[k]) for k in darp.vehicles)
    newRoutes[move.k1] = remove_from_route(valN, darp, curRoutes[move.k1], move.i)
    newRoutes[move.k2] = insert_to_route(valN, darp, curRoutes[move.k2], move.i, move.p1, move.p2)
    newRVals = Dict{Int64,RVals{N}}(k => RVals{N}(copy(curRVals[k].rmap), curRVals[k].A, curRVals[k].w, curRVals[k].B, curRVals[k].D, curRVals[k].y) for k in darp.vehicles)
    newRVals[move.k1] = route_values!(valN, darp, newRoutes[move.k1], nothing)
    newRVals[move.k2] = route_values!(valN, darp, newRoutes[move.k2], nothing)
    newOptRoutes = copyOptRoutes(darp, curOptRoutes)
    newOptRoutes.optRouteDict[move.k1] = calc_opt_for_route(valN, darp, newRoutes[move.k1], newRVals[move.k1])
    newOptRoutes.optRouteDict[move.k2] = calc_opt_for_route(valN, darp, newRoutes[move.k2], newRVals[move.k2])
    # println("#####################")
    # println(curRoutes[move.k1])
    # println(newRoutes[move.k1])
    return newRoutes, newRVals, reCalOptRoutes(darp, newOptRoutes)
end
