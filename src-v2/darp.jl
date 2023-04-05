# TODO -> make these config driven?
include("utils.jl")
include("parseRequests.jl")
using StaticArrays
using Test
using TimerOutputs
using StatsBase


DEFAULT_SERVICE_TIME = 2
DEFAULT_TW_OFFSET = 5 * 60 # 5 minutes in seconds
DEFAULT_WAITTIME_AT_PICKUP = 3 * 60 # 3 minutes in seconds

struct MoveParams
    i::Int64
    k1::Int64
    k2::Int64
    p1::Int64
    p2::Int64
    function MoveParams(i, k1, k2, p1, p2)
        return new(i, k1, k2, p1, p2)
    end
end
Base.zero(::Type{MoveParams}) = MoveParams(0, 0, 0, 0, 0)

const Route{N} = MVector{N,Int64}
const GenericRoute{N} = Union{Vector{Int64},Route{N}}
const Routes{N} = Dict{Int64,Route{N}}
const GenericRoutes{N} = Union{Dict{Int64,Route{N}},Dict{Int64,Vector{Int64}}}
const RMap = Dict{Int64,Int64}

struct RVals{N}
    rmap::RMap
    A::MVector{N,Float64} where {N}
    w::MVector{N,Float64} where {N}
    B::MVector{N,Float64} where {N}
    D::MVector{N,Float64} where {N}
    y::MVector{N,Float64} where {N}

    RVals{N}(rmap, A, w, B, D, y) where {N} = new(rmap, A, w, B, D, y)
end

const TabuMemory = Dict{MoveParams,Int64}


struct DARP
    nR::Int64
    sd::Float64 # in seconds
    aos::Int64 # in sqmiles
    nV::Int64
    T_route::Float64 # lets say a route can run as long as service duration
    requests::AbstractArray{Request}
    start_depot::Int64
    end_depot::Int64
    Q::Int64 # vehicle capacity
    coords::Dict{Int64,Point}
    d::Dict{Int64,Int64}
    q::Dict{Int64,Int64}
    tw::Dict{Int64,Tuple{Float64,Float64}}
    w::Dict{Int64,Float64}
    vehicles::AbstractArray{Int64}
    vehicleWeights::Weights{Int64, Int64, Vector{Int64}}
    requestWeights::Weights{Int64, Int64, Vector{Int64}}
    MAX_ROUTE_SIZE::Int64
    stats::DARPStat

    function DARP(nR::Int64, sd::Int64, aos::Int64, nV::Int64, Q::Int64, stats::DARPStat)
        start_depot::Int64 = 0
        end_depot::Int64 = 2 * nR + 1

        sdInSeconds::Float64 = sd * 60 * 60
        aosInSqMiles::Int64 = trunc(Int64, aos * 0.386102)
        T_route::Float64 = sdInSeconds * 0.5

        requests = parseData(nR, sd, aos)
        coords::Dict{Int64,Point} = Dict{Int64,Point}([])
        coords[start_depot] = requests[1].src
        coords[end_depot] = requests[1].dst

        d::Dict{Int64,Int64} = Dict{Int64,Int64}([])
        d[start_depot] = 0
        d[end_depot] = 0

        q::Dict{Int64,Int64} = Dict{Int64,Int64}([])
        q[start_depot] = 0
        q[end_depot] = 0

        tw::Dict{Int64,Tuple{Float64,Float64}} = Dict([])
        offset::Int64 = DEFAULT_TW_OFFSET
        tw[start_depot] = (0, offset)
        tw[end_depot] = (T_route, T_route + offset)

        w::Dict{Int64,Float64} = Dict{Int64,Float64}([])
        w[start_depot] = 0
        w[end_depot] = 0

        for req in requests[2:end]
            coords[req.id] = req.src
            coords[-req.id] = req.dst

            # data doesnt have specific service time at each node, so u;se const value
            d[req.id] = 2
            d[-req.id] = 2

            # change in load after each node
            q[req.id] = req.load
            q[-req.id] = -req.load

            tw[req.id] = (req.pickup_time, req.pickup_time + offset)
            tw[-req.id] = (req.dropoff_time, req.dropoff_time + offset)

            w[req.id] = DEFAULT_WAITTIME_AT_PICKUP
            w[-req.id] = 0
        end

        vehicleWeights = Weights(fill(1, nV))
        requestWeights = Weights(fill(1, nR))
        MAX_ROUTE_SIZE = trunc(Int64, nR / nV) + trunc(Int64, nR * 0.8)
        return new(nR, sdInSeconds, aosInSqMiles,
            nV, T_route, requests, start_depot, end_depot,
            Q, coords, d, q, tw, w, collect(nR+1:nR+nV),
            vehicleWeights, requestWeights,
            MAX_ROUTE_SIZE, stats)
    end
end

struct Move
    darp::DARP
    baseRoute::Routes
    moveParams::MoveParams
end

function travel_time(darp::DARP, one::Int64, two::Int64)
    pone = darp.coords[one]
    ptwo = darp.coords[two]
    return (abs(pone.x - ptwo.x) + abs(pone.y - ptwo.y))
end

function copyRoute!(src::Route, dest::Route)
    for idx in eachindex(src)
        dest[idx] = src[idx]
    end
end

function emptyRoute(darp::DARP)
    Route
    return zeros(MVector{darp.MAX_ROUTE_SIZE,Int64})
end
function emptyRoutes(darp::DARP)
    Routes
    return Dict(k => emptyRoute(darp) for k in darp.vehicles)
end

function emptyRValue(size)
    return zeros(MVector{size,Float64})
end

function emptyRValues(::Val{N}, darp::DARP) where {N}
    RVals
    r1 = emptyRValue(N)
    r2 = emptyRValue(N)
    r3 = emptyRValue(N)
    r4 = emptyRValue(N)
    r5 = emptyRValue(N)
    return RVals{N}(Dict{Int64,Int64}(), r1, r2, r3, r4, r5)
end

function insert_to_route(valN::Val{N}, darp::DARP, baseRoute::Route{N}, i::Int64, p1::Int64, p2::Int64) where {N}
    Route{N}
    newRoute = emptyRoute(darp)
    rIdx = 1
    ptr = 1
    while ptr <= N
        if ptr == p1
            newRoute[ptr] = i
            ptr += 1
            continue
        end
        if ptr == p2
            newRoute[ptr] = -i
            ptr += 1
            continue
        end
        newRoute[ptr] = baseRoute[rIdx]
        rIdx += 1
        ptr += 1
    end
    return newRoute
end

function remove_from_route(::Val{N}, darp::DARP, baseRoute::Route{N}, i::Int64) where {N}
    Route{N}
    newRoute = emptyRoute(darp)
    idx = 1
    for baseIdx in eachindex(baseRoute)
        if baseRoute[baseIdx] == i || baseRoute[baseIdx] == -i
            continue
        end
        newRoute[idx] = baseRoute[baseIdx]
        idx += 1
    end

    return newRoute
end

function generate_random_moves(::Val{N}, ::Val{N_SIZE}, iterationNum::Int64, tabuMem::TabuMemory,
    darp::DARP, baseRoutes::Routes{N}, destMoves::MVector{N_SIZE,MoveParams}) where {N,N_SIZE}
    MVector{N_SIZE,MoveParams}

    nR = darp.nR
    nV = darp.nV
    depotIndicies = Dict{Int64,Int64}()
    for k in darp.vehicles
        depotIndicies[k] = findlast(x -> x == darp.end_depot, baseRoutes[k])
    end
    routeRanges = Dict(k => 1:depotIndicies[k] for k in darp.vehicles)
    routeRangeWeights = Dict(k => Weights(fill(1, depotIndicies[k])) for k in darp.vehicles)
    TABU_SIZE = trunc(Int64, nR * 0.5)
    vehicles = collect(nR+1:nR+nV)
    vehicleWeights = Weights(fill(1, nV))

    tabuMissCount = 0
    seedRng = MersenneTwister(iterationNum)
    idx = 1
    while idx <= N_SIZE
        # rng = MersenneTwister(seed)
        k1, k2 = StatsBase.sample(seedRng, vehicles, vehicleWeights, 2, replace=false)
        if depotIndicies[k1] <= 2
            continue
        end
        # pick a request from k1
        # IMPROVEMENT: Use range on index rather than routes
        iIdx = StatsBase.sample(seedRng, routeRanges[k1], routeRangeWeights[k1], 1)
        i = baseRoutes[k1][iIdx]
        i = abs(i[1])
        if i == darp.start_depot || i == darp.end_depot
            continue
        end
        len_k2::Int64 = depotIndicies[k2]
        if len_k2 == 0
            continue
        end

        p1, p2 = StatsBase.sample(seedRng, 1:len_k2, Weights(fill(1, len_k2)), 2, replace=false, ordered=true)
        if p1 == 1 || p2 == len_k2
            continue
        end
        param = MoveParams(i, k1, k2, p1, p2)
        destMoves[idx] = param
        idx += 1
        # TODO: Tabu search
    end
    return destMoves
end

function copyVectorRoute!(::Val{N}, darp, srcRoute::Vector{Int64}, destRoute::Route{N}) where {N}
    for idx in eachindex(srcRoute)
        destRoute[idx] = srcRoute[idx]
    end
    return destRoute
end
