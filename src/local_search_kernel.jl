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
INTRA_ROUTE_KAPPA = 10
NIT = 3 # from granual-tabu-search paper
RESET_ITERATIONS = 50

function search(valN::Val{N}, darp::DARP, bks::Float64, mrt::Int64, N_SIZE::Int, initRoutes::Routes, va::VoilationVariables, stats::DARPStat, to::TimerOutput) where {N}
    useBKSToStop = bks != 0
    useMRTToStop = mrt != 0
    searchStart = now()
    printRoutes(initRoutes, darp)

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
    bestMove::MoveParams = MoveParams(0, 0, 0, 0, 0, false) # just some placeholder value, will be changed when it is actually used

    # printRoutesDetailed(curRoutes, darp, curOptRoutes)

    iterNum = 1
    continueIntraRoute = true
    lastImprovedIterNum = 0

    while true
        println("###################")
        if ((iterNum - lastImprovedIterNum) % RESET_ITERATIONS) == 0
            println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            println("Resetting Memories and randomizing coefficients")
            println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            va = va.resetMemories(va)
            va = randomize_coefficients(va, darp.nR)
            va = reset_theta(va, darp.nR)
        elseif iterNum % KAPPA == 0
            va = randomize_coefficients(va, darp.nR)
            println("Randomized Constants")
        elseif iterNum > 1 && curOptRoutes.feasible
            va = decrease_penality_coefficients(va)
            println("Decreasing Penality Coefficients")
        elseif iterNum > 1
            va = increase_penality_coefficients(va)
            println("Increasing Penality Coefficients")
        end

        if iterNum == 1 || (iterNum % INTRA_ROUTE_KAPPA == 0 && continueIntraRoute)
            println("Attempting INTRA ROUTE optimization")
            beforeVal = bestOptValue
            newRoutes = Dict{Int64,Route{N}}(k => copy(curRoutes[k]) for k in darp.vehicles)
            # perform intra route optimization
            Threads.@threads for vid in darp.vehicles
                intraOptimizedRoute = performIntraRouteOptimimzation(valN, vid, newRoutes[vid], bestOptRoutes, darp, va)
                newRoutes[vid] = intraOptimizedRoute
            end

            # recalc the best values
            newRVals = Dict(k => route_values!(valN, darp, newRoutes[k], nothing) for k in darp.vehicles)
            # this is tricky, we still want to use the penlity and other scaling factors
            newOptRouteDict = Dict{Int64,OptRoute}(k => calc_opt_for_route(valN, darp, newRoutes[k], newRVals[k]) for k in darp.vehicles)
            # carry forward the penality
            # newOptRoutes = OptRoutes(newOptRouteDict, va, curOptRoutes.lastMove, curOptRoutes.moveIncludedInLongMemory)
            newOptRoutes = OptRoutes(newOptRouteDict, va, nothing, false)
            newOptValue = newOptRoutes.Val

            if newOptValue < beforeVal
                println("Intra Route => Before = $(beforeVal) | After = $(bestOptRoutes.Val)")
                va = va.resetMemories(va)
            else
                continueIntraRoute = false
            end

            tabuMissCount = 0
        else
            @timeit to "localsearch#$(iterNum)" begin
                @timeit to "randomMove" begin
                    tabuMissCount, va = generate_random_moves(valN, Val(N_SIZE), iterNum, darp, curRoutes, curOptRoutes, moves, va)
                end
                @timeit to "localsearch" begin
                    bestTid = local_search(Val(N), Val(N_SIZE), darp, N_SIZE, scores, moves, curRoutes, curOptRoutes, bestOptValue, to, va)
                end
            end
            # best move among the randomly generated moves
            bestMove = moves[bestTid]
            println(bestMove)

            # add it to longmemory that this move is part of solution
            if !haskey(va.LongerTermTabuMemory, (bestMove.i, bestMove.k2))
                va.LongerTermTabuMemory[(bestMove.i, bestMove.k2)] = 0
            end
            va.LongerTermTabuMemory[(bestMove.i, bestMove.k2)] += 1

            newRoutes, newRVals, newOptRoutes = apply_move(valN, darp, bestMove, curRoutes, curRVals, curOptRoutes, va)
            newOptValue = newOptRoutes.Val
        end

        if newOptValue < bestOptValue && newOptRoutes.feasible
            bestRoutes = newRoutes
            bestRVals = newRVals
            bestOptRoutes = newOptRoutes
            bestOptValue = newOptValue
            lastImprovedIterNum = iterNum
        end
        println("$(iterNum) | feasible=$(newOptRoutes.feasible) | TabuTenure=$(va.THETA) | best=$(bestOptValue) | cur=$(curOptValue) | lastImprovedIterNum=$(lastImprovedIterNum)")

        # use the new ones as current and continue
        curRoutes, curRVals, curOptRoutes, curOptValue = newRoutes, newRVals, newOptRoutes, newOptValue

        improved = percentage_improved(baseVal, bestOptValue)
        gap = bestOptValue - bks
        if bestOptRoutes.Val < 0
            println("Negative OptVal: $(bestOptRoutes.Val)")
            println(bestOptRoutes)
            println("Stopping")
            break
        end

        optValuesLog[iterNum] = bestOptRoutes.Val

        if useBKSToStop && gap <= 0
            println("Stopping Criteria => Best Known SOlution reached")
            println("Total Iterations: $(iterNum)")
            stats.total_iterations = iterNum
            break
        elseif useMRTToStop && ts_diff(searchStart, now()) > mrt
            println("Stopping Criteria => Max RunTime reached")
            println("Total Iterations: $(iterNum)")
            stats.total_iterations = iterNum
            break
        end

        printRoutesDetailed(curRoutes, darp, curOptRoutes)

        if iterNum > NIT && iterNum % NIT == 0
            # time to check the history and modify the tabu tenure if required
            improved = false
            base = optValuesLog[iterNum-NIT]
            for x in iterNum-NIT-1:iterNum
                if optValuesLog[x] > base
                    improved = true
                end
            end
            if improved # probably exploring good-neighborhood, intensify
                println("increasing THETA")
                va = increase_theta(va, darp.nR)
            else # probably in local optimum, diversify
                println("decreasing THETA")
                va = decrease_theta(va, darp.nR)
            end
        end

        iterNum += 1
    end
    return bestRoutes, bestOptRoutes
end

function local_search(valN::Val{N}, ::Val{NSIZE}, darp::DARP, N_SIZE::Int, scores::MVector{NSIZE}, moves::MVector{NSIZE,MoveParams}, baseRoute::Routes{N}, baseOptRoutes::OptRoutes, bestOptVal::Float64, to::TimerOutput, va::VoilationVariables) where {N,NSIZE}
    # use each allocated space and do the work.....
    tabuedScores = fill(Inf, N_SIZE)
    Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        optRoute::OptRoutes = calc_opt_incr(valN, darp, baseRoute, move, baseOptRoutes, va)
        scores[tid] = optRoute.Val
        if move.isFromTabu
            tabuedScores[tid] = optRoute.Val
        end
    end
    minTabuedScore, minTidTabued = findmin(tabuedScores)
    minScore, minTid = findmin(scores)
    # use tabued move if it beating the best so far
    if minTabuedScore != Inf && minTabuedScore < minScore && minTabuedScore < best
        return minTidTabued
    end

    return minTid
end
