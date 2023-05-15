import Base.Threads
import StatsBase
using Distributions
import Random
import StaticArrays
import TimerOutputs

include("darp.jl")
include("utils.jl")
const Int = Int64
KAPPA = 15 # iterations after which intra-route optimzation is performed
INTRA_ROUTE_KAPPA = 15

function search(valN::Val{N}, darp::DARP, bks::Float64, mrt::Int64, N_SIZE::Int, initRoutes::Routes, va::VoilationVariables, stats::DARPStat, to::TimerOutput) where {N}
    useBKSToStop = bks != 0
    useMRTToStop = mrt != 0
    searchStart = now()

    # Initialize current variable
    scores = zeros(MVector{N_SIZE})
    curRoutes = initRoutes
    curRVals::Dict{Int64,RVals{N}} = Dict(k => route_values!(valN, darp, curRoutes[k], nothing) for k in darp.vehicles)
    # since these are brand new generate, calc full
    curOptRoutes::OptRoutes = calc_opt_full(valN, darp, curRVals, curRoutes, va)
    curOptValue::Float64 = curOptRoutes.Val
    moves::MVector{N_SIZE,MoveParams} = zeros(MVector{N_SIZE,MoveParams})

    # Initialize best variables
    bestRoutes::Routes{N} = initRoutes
    bestOptRoutes::OptRoutes = curOptRoutes
    bestRVals::Dict{Int64,RVals{N}} = curRVals
    bestOptValue::Float64 = bestOptRoutes.Val

    baseVal = bestOptValue
    optValuesLog = Dict{Int64,Float64}([])
    bestMove::MoveParams = MoveParams(0, 0, 0, 0, 0) # just some placeholder value, will be changed when it is actually used

    iterNum = 1
    while true
        if iterNum % KAPPA == 0
            va = randomize_coefficients(va, darp.nR)
        else
            va = decrease_penality_coefficients(va)
        end

        # if iterNum % KAPPA == 0
        #     beforeVal = bestOptValue
        #     # perform intra route optimization
        #     Threads.@threads for vid in darp.vehicles
        #         intraOptimizedRoute = performIntraRouteOptimimzation(valN, vid, bestRoutes[vid], bestOptRoutes, darp, va)
        #         bestRoutes[vid] = intraOptimizedRoute
        #     end
        #     # recalc the best values
        #     bestRVals = Dict(k => route_values!(valN, darp, bestRoutes[k], nothing) for k in darp.vehicles)
        #     # this is tricky, we still want to use the penlity and other scaling factors
        #     optRouteDict = Dict{Int64,OptRoute}(k => calc_opt_for_route(valN, darp, bestRoutes[k], bestRVals[k]) for k in darp.vehicles)
        #     # carry forward the penality
        #     bestOptRoutes = OptRoutes(optRouteDict, va, (bestMove.i, bestMove.k2), true)
        #     bestOptValue = bestOptRoutes.Val

        #     # assign best to cur
        #     curRoutes = bestRoutes
        #     curOptRoutes = bestOptRoutes
        #     curRVals = bestRVals
        #     curOptValue = curOptRoutes.Val # no Penality here because no move

        #     iterNum += 1
        #     println("Intra Route => Before = $(beforeVal) | After = $(bestOptRoutes.Val)")
        #     if iterNum > mrt
        #         println("Stopping Criteria - Max Runtime reached")
        #         break
        #     else
        #         continue
        #     end
        # end

        @timeit to "localsearch#$(iterNum)" begin
            @timeit to "randomMove" begin
                tabuMissCount, vc = generate_random_moves(valN, Val(N_SIZE), iterNum, darp, curRoutes, moves, va)
            end
            @timeit to "localsearch" begin
                bestTid = local_search(Val(N), Val(N_SIZE), darp, N_SIZE, scores, moves, curRoutes, curOptRoutes, to, vc)
            end
        end
        # best move among the randomly generated moves
        bestMove = moves[bestTid]

        # add it to longmemory that this move is part of solution
        if !haskey(va.LongerTermTabuMemory, (bestMove.i, bestMove.k2))
            va.LongerTermTabuMemory[(bestMove.i, bestMove.k2)] = 0
        end
        va.LongerTermTabuMemory[(bestMove.i, bestMove.k2)] += 1

        newRoutes, newRVals, newOptRoutes = apply_move(valN, darp, bestMove, curRoutes, curRVals, curOptRoutes, vc)
        newOptValue = newOptRoutes.Val

        if newOptValue < bestOptValue
            bestRoutes = newRoutes
            bestRVals = newRVals
            bestOptRoutes = newOptRoutes
            bestOptValue = newOptValue
        end

        if bestOptRoutes.Val < 0
            println("Negative OptVal: $(bestOptRoutes.Val)")
            println(bestOptRoutes)
            println("Stopping")
            break
        end

        optValuesLog[iterNum] = bestOptRoutes.Val

        # use the new ones as current and continue
        curRoutes, curRVals, curOptRoutes, curOptValue = newRoutes, newRVals, newOptRoutes, newOptValue

        improved = percentage_improved(baseVal, bestOptValue)
        gap = bestOptValue - bks
        println("$(iterNum) | gap=$(gap) | Tt=$(vc.THETA) | tabuMissCount=$(tabuMissCount) | best=$(bestOptValue) | cur=$(curOptValue)")
        if useBKSToStop && gap <= 0
            println("Stopping Criteria => Best Known SOlution reached")
            println("Total Iterations: $(iterNum)")
            stats.total_iterations = iterNum
            break
        elseif useMRTToStop && iterNum > mrt
            println("Stopping Criteria => Max RunTime reached")
            println("Total Iterations: $(iterNum)")
            stats.total_iterations = iterNum
            break
        end

        iterNum += 1
    end
    return bestRoutes, bestOptRoutes
end

function local_search(valN::Val{N}, ::Val{NSIZE}, darp::DARP, N_SIZE::Int, scores::MVector{NSIZE}, moves::MVector{NSIZE,MoveParams}, baseRoute::Routes{N}, baseOptRoutes::OptRoutes, to::TimerOutput, va::VoilationVariables) where {N,NSIZE}
    # use each allocated space and do the work.....
    Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        optRoute::OptRoutes = calc_opt_incr(valN, darp, baseRoute, move, baseOptRoutes, va)
        scores[tid] = optRoute.Val
    end
    _, minTid = findmin(scores)
    return minTid
end
