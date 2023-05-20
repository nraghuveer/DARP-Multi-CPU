include("utils.jl")
include("parseRequests.jl")
include("parseBenchmarkData.jl")
using StaticArrays
using Test
using TimerOutputs
using StatsBase

struct MoveParams
    i::Int64
    k1::Int64
    k2::Int64
    p1::Int64
    p2::Int64
    isFromTabu::Bool
    function MoveParams(i, k1, k2, p1, p2, isFromTabu::Bool)
        return new(i, k1, k2, p1, p2, isFromTabu)
    end
end
Base.zero(::Type{MoveParams}) = MoveParams(0, 0, 0, 0, 0, false)




# (i, k)
const TabuMemory = Dict{Tuple{Int64,Int64},Int64}

mutable struct VoilationVariables
    LAMBDA::Float64
    ALPHA::Float64 #q(s)
    BETA::Float64 # d(s)
    GAMMA::Float64 #w(s)
    TAU::Float64 # t(s)

    THETA::Float64
    ZETA::Float64
    LongerTermTabuMemory::Dict{Tuple{Int64,Int64},Int64}
    ShortTermTabuMemory::TabuMemory
    sqrt_nm::Float64
    checkTabuMem::Function
    resetMemories::Function

    function VoilationVariables(nR::Int64, nV::Int64)
        # sqrt of n*m
        sqrt_nm = sqrt(nR * nV)


        checkTabuMem::Function = function (i::Int64, move::MoveParams, va::VoilationVariables)
            # route request i is added to vehicle route k2
            m = (move.i, move.k2)
            if !haskey(va.ShortTermTabuMemory, m) || va.ShortTermTabuMemory[m] <= i
                va.ShortTermTabuMemory[m] = ceil(Int64, va.THETA)
                return true, va, -1
            end
            return false, va, get(va.ShortTermTabuMemory, m, 0)
        end

        resetMemories::Function = function (va::VoilationVariables)
            va.LongerTermTabuMemory = Dict{Tuple{Int64,Int64},Int64}([])
            va.ShortTermTabuMemory = TabuMemory()
            return va
        end
        Tt = 7.5 * log10(nR)
        return new(0.015, 1.0, 1.0, 1.0, 1.0, Tt, 0.51, Dict{Tuple{Int64,Int64},Int64}([]), TabuMemory(), sqrt_nm, checkTabuMem, resetMemories)
    end
end



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



struct DARP
    nR::Int64
    nV::Int64
    T_route::Float64 # max route duration
    requests::AbstractArray{Request}
    requestsDict::Dict{Int64,Request}
    start_depot::Int64
    end_depot::Int64
    Q::Int64 # vehicle capacity
    coords::Dict{Int64,Point}
    d::Dict{Int64,Int64}
    q::Dict{Int64,Int64}
    tw::Dict{Int64,Tuple{Float64,Float64}}
    standardCost::Float64
    vehicles::AbstractArray{Int64}
    vehicleWeights::Weights{Int64,Int64,Vector{Int64}}
    requestWeights::Weights{Int64,Int64,Vector{Int64}}
    MAX_ROUTE_SIZE::Int64
    stats::DARPStat

    function DARP(datafile::String, stats::DARPStat)
        filepath = string("benchmark-data/chairedistributique/data/darp/tabu/", datafile)
        println("using datafile = $(filepath)")
        requests, requestsDict, depotPoint, depotTW, nR, nV, Q, T_route = parseFile(filepath)
        start_depot = 0
        end_depot = nR + 1

        coords::Dict{Int64,Point} = Dict{Int64,Point}([])
        coords[start_depot] = depotPoint
        coords[end_depot] = depotPoint

        d::Dict{Int64,Int64} = Dict{Int64,Int64}([])
        d[start_depot] = 0
        d[end_depot] = 0

        q::Dict{Int64,Int64} = Dict{Int64,Int64}([])
        q[start_depot] = 0
        q[end_depot] = 0

        tw::Dict{Int64,Tuple{Float64,Float64}} = Dict([])
        tw[start_depot] = depotTW
        tw[end_depot] = depotTW

        standardCost = 0.0

        for req in requests[1:end]
            coords[req.id] = req.src
            coords[-req.id] = req.dst

            # data doesnt have specific service time at each node, so u;se const value
            d[req.id] = req.pickup_servicetime
            d[-req.id] = req.dropoff_servicetime

            # change in load after each node
            q[req.id] = req.pickup_load
            q[-req.id] = req.dropoff_load

            # # tighten time windows?
            # ei_pickup_old, li_pickup_old = req.pickup_tw
            # ei_drop_old, li_drop_old = req.dropoff_tw

            # L = travel_time(req.src, req.dst)
            # ei_pickup_new = max(ei_pickup_old,
            #     ei_drop_old - d[-req.id] - L)
            # li_pickup_new = min(li_pickup_old, li_drop_old - d[req.id])

            # ei_dropoff_new = max(ei_drop_old, ei_pickup_old + d[req.id])
            # li_dropoff_new = min(li_drop_old, li_pickup_old + d[req.id] + L)

            # li_pickup_new = 0
            # tw[req.id] = (ei_pickup_new, li_pickup_new)
            # tw[-req.id] = (ei_dropoff_new, li_dropoff_new)

            tw[req.id] = req.pickup_tw
            tw[-req.id] = req.dropoff_tw

            standardCost += travel_time(req.src, req.dst)
        end

        vehicleWeights = Weights(fill(1, nV))
        requestWeights = Weights(fill(1, nR))
        MAX_ROUTE_SIZE = nR * 4

        return new(nR, nV, T_route, requests, requestsDict, start_depot, end_depot,
            Q, coords, d, q, tw, standardCost, collect(nR+2:nR+2+nV-1), # inclusive
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
    return sqrt((ptwo.x - pone.x)^2 + (ptwo.y - pone.y)^2)
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

function copyVectorRoute!(::Val{N}, darp, srcRoute::Vector{Int64}, destRoute::Route{N}) where {N}
    for idx in eachindex(srcRoute)
        destRoute[idx] = srcRoute[idx]
    end
    return destRoute
end

function printRoutes(routes::Routes{N}, darp::DARP) where {N}
    for k in sort(darp.vehicles)
        route = routes[k]
        result = Array{Int64}([])
        for v in route
            if v == darp.end_depot
                push!(result, v)
                break
            end
            push!(result, v)
        end
        println("$(k) => $(result)")
    end
end

function randomize_coefficients(vc::VoilationVariables, nR::Int64)
    # vc.THETA = rand(Uniform(0.0, 7.5 * log10(nR)))
    vc.LAMBDA = rand(Uniform(0.0, 0.015))
    vc.ZETA = rand(Uniform(0, 0.5))
    return vc
end

function reset_theta(va::VoilationVariables, nR::Int64)
    va.THETA = 7.5 * log10(nR)
    return va
end

function increase_theta(va::VoilationVariables, nR::Int64)
    T = 7.5 * log10(nR)
    MAX_VALUE = T + (0.7 * T)
    va.THETA = max(MAX_VALUE, va.THETA + (0.2 * va.THETA))
    return va
end

function decrease_theta(va::VoilationVariables, nR::Int64)
    T = 7.5 * log10(nR)
    MIN_VALUE = T - (0.7 * T)
    va.THETA = min(MIN_VALUE, va.THETA - (0.2 * va.THETA))
    return va
end

function decrease_penality_coefficients(va::VoilationVariables)
    if va.ZETA <= 0
        return va
    end
    va.ALPHA = max(0.0, va.ALPHA / (1 + va.ZETA))
    va.BETA = max(0.0, va.BETA / (1 + va.ZETA))
    va.GAMMA = max(0.0, va.GAMMA / (1 + va.ZETA))
    va.TAU = max(0.0, va.TAU / (1 + va.ZETA))
    return va
end

function increase_penality_coefficients(va::VoilationVariables)
    if va.ZETA <= 0
        return va
    end
    va.ALPHA = max(0.0, va.ALPHA * (1 + va.ZETA))
    va.BETA = max(0.0, va.BETA * (1 + va.ZETA))
    va.GAMMA = max(0.0, va.GAMMA * (1 + va.ZETA))
    va.TAU = max(0.0, va.TAU * (1 + va.ZETA))
    return va
end
