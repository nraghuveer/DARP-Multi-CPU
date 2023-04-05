import Base.Threads
import StatsBase
import Random
import StaticArrays
import TimerOutputs

include("darp.jl")
include("utils.jl")
const Int = Int64


function search(valN::Val{N}, darp::DARP, iterations::Int, N_SIZE::Int, initRoutes::Routes, stats::DARPStat, to::TimerOutput) where {N}
    tabuMem = TabuMemory()

    @timeit to "searchInit" begin
        scores = zeros(MVector{N_SIZE})
        curRoutes = initRoutes
        curRVals::Dict{Int64,RVals{N}} = Dict(k => route_values!(valN, darp, curRoutes[k], nothing) for k in darp.vehicles)
        curOptRoutes::OptRoutes = calc_opt_full(valN, darp, curRVals, curRoutes)
        moves::MVector{N_SIZE,MoveParams} = zeros(MVector{N_SIZE,MoveParams})
    end


    bestRoutes::Routes{N} = initRoutes
    bestOptRoutes::OptRoutes = curOptRoutes
    bestRVals::Dict{Int64, RVals{N}} = curRVals

    baseVal = curOptRoutes.Val

    # TODO: tabu memory
    for iterNum in 1:iterations
        @timeit to "localsearch#$(iterNum)" begin
            @timeit to "randomMove" begin
                generate_random_moves(valN, Val(N_SIZE), iterNum, tabuMem, darp, curRoutes, moves)
            end
            @timeit to "localsearch" begin
                bestTid = local_search(Val(N), Val(N_SIZE), darp, N_SIZE, scores, moves, curRoutes, curOptRoutes, to)
            end
        end
        # use bestTid to update the cur values
        # DO we really want to always applY?????
        bestMove = moves[bestTid]
        newRoutes, newRVals, newOptRoutes = apply_move(valN, darp, bestMove, curRoutes, curRVals, curOptRoutes)
        if newOptRoutes.Val < bestOptRoutes.Val
            bestRoutes = newRoutes
            bestRVals = newRVals
            bestOptRoutes = newOptRoutes
        end

        # use the new ones as current and continue
        curRoutes, curRVals, curOptRoutes = newRoutes, newRVals, newOptRoutes
        improved = percentage_improved(baseVal, curOptRoutes.Val)
        println("$(iterNum)/$(iterations) | voilation=$(curOptRoutes.Val) | improved=$(improved)")
        println("Free Memory $(freeMem())")
    end
end

function local_search(valN::Val{N}, ::Val{NSIZE}, darp::DARP, N_SIZE::Int, scores::MVector{NSIZE}, moves::MVector{NSIZE,MoveParams}, baseRoute::Routes{N}, baseOptRoutes::OptRoutes, to::TimerOutput) where {N,NSIZE}
    GC.gc(false)
    # use each allocated space and do the work.....
    Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        optRoute::OptRoutes = calc_opt_incr(valN, darp, baseRoute, move, baseOptRoutes)
        scores[tid] = optRoute.Val
    end
    _, minTid = findmin(scores)
    return minTid
end
