import Base.Threads
import StatsBase
import Random
using StaticArrays
include("optimization_fn.jl")
include("darp.jl")
include("utils.jl")

using TimerOutputs

@inline calc_opt_inline(darp::DARP, rvalues::Dict{Int64,SRVALS}, routes::Route) = calc_opt(darp, rvalues, routes)
@inline route_values_inline(route::AbstractArray{Int64}, darp::DARP) = route_values(route, darp)

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

# Route should include start and end
function local_search(darp::DARP, iterations::Int64, N_SIZE::Int64, baseRoute::Route, stats::DARPStat, to::TimerOutput)

    tabuMem = TabuMemory()
    rvalues = Dict(k => route_values_inline(baseRoute[k], darp) for k in keys(baseRoute))
    baseVal::Float64 = calc_opt_inline(darp, rvalues, baseRoute)

    bestRoute = baseRoute
    bestVal = baseVal

    curRoute = baseRoute
    curVal = baseVal

    for curIteration in 1:iterations
        @timeit to "search#$(curIteration)" begin
            newMove::MoveParams, newVal::Float64 =
                do_local_search!(curIteration, tabuMem, darp, curRoute, N_SIZE, to)
            newRoute = apply_move_inline(curRoute, newMove)

            if newVal <= bestVal
                bestVal = newVal
                bestRoute = newRoute
            end
            improvement = percentage_improved(baseVal, bestVal)

            println("$(curIteration)/$(iterations) | voilation=$(newVal) | improved=$(100 - improvement)%")
            curRoute = newRoute
            curVal = newVal
        end
    end

    best_improvement = percentage_improved(baseVal, bestVal)
    stats.best_improvement = 100.0 - best_improvement

    # convert the stack array to heap array
    resultRoute = Dict(k => [x for x in bestRoute] for k in keys(bestRoute))
    return resultRoute, bestVal
end

function generate_random_moves(iterationNum::Int64, tabuMem::TabuMemory,
        nR::Int64, nV::Int64,
        size::Int64, routes::Route, start_depot, end_depot)
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
        if i == start_depot || i == end_depot
            continue
        end
        len_k2::Int64 = length(routes[k2])
        if len_k2 == 0
            continue
        end
        p1, p2 = StatsBase.sample(seedRng, 1:len_k2, Weights(fill(1, len_k2)),
            2, replace=false, ordered=true)
        if p1 == 1 || p2 == len_k2
            continue
        end
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

function apply_move(routes::Route, move::MoveParams) Route
    newRoutes = Dict(k => deepcopy(routes[k]) for k in keys(routes))
    # remove "i" from k1 route
    # newRoutes[move.k1] = deepcopy(routes[move.k1])
    # newRoutes[move.k2] = deepcopy(routes[move.k2])
    deleteat!(newRoutes[move.k1], findall(x -> abs(x) == move.i, newRoutes[move.k1]))
    insert!(newRoutes[move.k2], move.p1, move.i)
    insert!(newRoutes[move.k2], move.p2, -move.i)
    return newRoutes
end

@inline apply_move_inline(routes::Route, move::MoveParams) = apply_move(routes, move)

function do_local_search!(iterationNum::Int64, tabuMem::TabuMemory,
            darp::DARP, routes::Route, N_SIZE::Int64, to::TimerOutput)
    GC.gc(false)

    @timeit to "prevRValues" prev_rvalues::Dict{Int64, SRVALS} = Dict(
            k => route_values(routes[k], darp) for k in keys(routes))

    @timeit to "moveGen" moves, _ = generate_random_moves(iterationNum, tabuMem, darp.nR,
                darp.nV, N_SIZE, routes, darp.start_depot, darp.end_depot)

    for move in moves
        tabuMem[move] = iterationNum
    end

    scores = zeros(N_SIZE)

    @timeit to "calcOptVal" Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        newRoutes::Route = apply_move_inline(routes, move)
        rvalues::Dict{Int64, SRVALS} = Dict(k => prev_rvalues[k] for k in filter((kk) -> kk != move.k1 && kk != move.k2, keys(prev_rvalues)))
        rvalues[move.k1] = route_values_inline(newRoutes[move.k1], darp)
        rvalues[move.k2] = route_values_inline(newRoutes[move.k2], darp)
        scores[tid] = calc_opt_inline(darp, rvalues, newRoutes)
        for k in [move.k1, move.k2]
            empty!(rvalues[k][1])
            for i in 1:5
                empty!(rvalues[k][2][i])
            end
        end
        empty!(newRoutes)
    end

    minScore, idx = findmin(scores)
    empty!(scores)
    empty!(tabuMem)
    return moves[idx], minScore
end
