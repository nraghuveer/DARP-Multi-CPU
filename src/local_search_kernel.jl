import Base.Threads
import StatsBase
import Random
include("optimization_fn.jl")
include("darp.jl")
include("utils.jl")

using TimerOutputs


struct MoveParams
    i::Int64
    k1::Int64
    k2::Int64
    p1::Int64
    p2::Int64
end

function percentage_improved(old::Float64, new::Float64)
    Float64
    return (new * 100) / old
end

const TabuMemory = Dict{MoveParams,Int64}

function local_search(darp::DARP, iterations::Int64,
    N_SIZE::Int64, rawInitRoute::Route, stats::DARPStat, to::TimerOutput)

    tabuMem = TabuMemory()
    bestRoute::Route = rawInitRoute
    routes_opt::Route = Dict(k => [[darp.start_depot]; bestRoute[k]; [darp.end_depot]]
                             for k in keys(bestRoute))
    rvalues = Dict(k => route_values(routes_opt[k], darp) for k in keys(routes_opt))
    bestVal::Float64 = calc_opt(-1, darp, rvalues, routes_opt, to)
    initVal::Float64 = bestVal
    curRoute = bestRoute
    curVal = bestVal

    for curIteration in 1:iterations
        @timeit to "search#$(curIteration)" begin
            newRoute::Route, newVal::Float64 = do_local_search!(curIteration, tabuMem, darp, curRoute, N_SIZE, to)
            if newVal <= bestVal
                bestRoute = newRoute
                bestVal = newVal
            end
            improvement = percentage_improved(initVal, bestVal)

            println("$(curIteration)/$(iterations) | voilation=$(newVal) | improved=$(100 - improvement)%")
            curRoute = newRoute
            curVal = newVal
        end
    end

    best_improvement = percentage_improved(initVal, bestVal)
    stats.best_improvement = 100.0 - best_improvement
    return bestRoute, bestVal
end

function generate_random_moves(iterationNum::Int64, tabuMem::TabuMemory,
    nR::Int64, nV::Int64,
    size::Int64, routes::Route)
    TABU_SIZE = trunc(Int64, nR * 0.5)
    moves::Set{MoveParams} = Set([])
    vehicles = collect(nR+1:nR+nV)
    vehicleWeights = Weights(fill(1, nV))

    tabuMissCount = 0
    seedRng = MersenneTwister(iterationNum)
    while length(moves) < size
        # rng = MersenneTwister(seed)
        k1, k2 = StatsBase.sample(seedRng, vehicles, vehicleWeights, 2, replace=false)
        if length(routes[k1]) == 0
            continue
        end
        # pick a request from k1
        i = StatsBase.sample(seedRng, routes[k1], Weights(fill(1, length(routes[k1]))), 1)
        i = abs(i[1])
        len_k2::Int64 = length(routes[k2])
        if len_k2 == 0
            continue
        end
        p1, p2 = StatsBase.sample(seedRng, 1:len_k2, Weights(fill(1, len_k2)),
            2, replace=false, ordered=true)
        param = MoveParams(i, k1, k2, p1, p2)
        moveLastUsedIn = get(tabuMem, param, -TABU_SIZE)
        if !(param in moves) && (moveLastUsedIn + TABU_SIZE <= iterationNum)
            tabuMem[param] = iterationNum
            push!(moves, param)
        else
            tabuMissCount += 1
        end
    end
    return collect(moves), tabuMissCount
end

function apply_move(routes::Route, move::MoveParams)
    newRoutes = deepcopy(routes)
    # remove "i" from k1 route
    deleteat!(newRoutes[move.k1], findall(x -> abs(x) == move.i, newRoutes[move.k1]))
    insert!(newRoutes[move.k2], move.p1, move.i)
    insert!(newRoutes[move.k2], move.p2, -move.i)
    return newRoutes
end

function do_local_search!(iterationNum::Int64, tabuMem::TabuMemory,
    darp::DARP, routes::Route, N_SIZE::Int64, to::TimerOutput)
    # if iterationNum % 20 == 0
    #     GC.gc(false)
    # end
    GC.gc(false)

    @timeit to "prevRValues" prev_rvalues = Dict(
        k => route_values([[darp.start_depot]; routes[k]; [darp.end_depot]], darp)
        for k in keys(routes))

    @timeit to "moveGen" moves, _ = generate_random_moves(iterationNum, tabuMem, darp.nR,
        darp.nV, N_SIZE, routes)

    for move in moves
        tabuMem[move] = iterationNum
    end

    scores = fill(floatmin(Float64), N_SIZE)

    @timeit to "calcOptVal" Threads.@threads for tid in 1:N_SIZE
        to2 = TimerOutput()
        move = moves[tid]
        newRawRoutes::Route = apply_move(routes, move)
        newRoutes::Route = Dict(k => [[darp.start_depot]; newRawRoutes[k]; [darp.end_depot]]
                                for k in keys(newRawRoutes))
        rvalues = deepcopy(prev_rvalues)
        rvalues[move.k1] = route_values(newRoutes[move.k1], darp)
        rvalues[move.k2] = route_values(newRoutes[move.k2], darp)
        disable_timer!(to2)
        scores[tid] = calc_opt(tid, darp, rvalues, newRoutes, to2)
        merge!(to, to2, tree_point=["search#$(iterationNum)"])
        enable_timer!(to2)
    end


    minScore, idx = findmin(scores)
    return apply_move(routes, moves[idx]), minScore
end
