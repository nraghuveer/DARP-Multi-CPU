import Base.Threads
import StatsBase
using Distributions
import Random
import StaticArrays
import TimerOutputs

include("darp.jl")
include("utils.jl")
const Int = Int64
KAPPA = 10 # iterations after which intra-route optimzation is performed

function search(valN::Val{N}, darp::DARP, bks::Float64, mrt::Int64, N_SIZE::Int, initRoutes::Routes, stats::DARPStat, to::TimerOutput) where {N}
    useBKSToStop = bks != 0
    useMRTToStop = mrt != 0
    searchStart = now()

    vc = VoilationCoefficients(darp.nR)
    println("Using $(vc)")

    # Penalized diversification strategy
    attributeFrequency = Dict{Tuple{Int64, Int64}, Int64}([])
    tabuMem = TabuMemory()

    @timeit to "searchInit" begin
        scores = zeros(MVector{N_SIZE})
        curRoutes = initRoutes
        curRVals::Dict{Int64,RVals{N}} = Dict(k => route_values!(valN, darp, curRoutes[k], nothing) for k in darp.vehicles)
        curOptRoutes::OptRoutes = calc_opt_full(valN, darp, curRVals, curRoutes, vc)
        moves::MVector{N_SIZE,MoveParams} = zeros(MVector{N_SIZE,MoveParams})
    end


    bestRoutes::Routes{N} = initRoutes
    bestOptRoutes::OptRoutes = curOptRoutes
    bestRVals::Dict{Int64,RVals{N}} = curRVals

    baseVal = curOptRoutes.Val

    optValuesLog = Dict{Int64,Float64}([])

    iterNum = 1
    while true
        if iterNum % KAPPA == 0
            vc = randomize_coefficients(vc, darp.nR)
       end
        vc = calc_penalities(vc)
        @timeit to "localsearch#$(iterNum)" begin
            @timeit to "randomMove" begin
                tabuMissCount, vc = generate_random_moves(valN, Val(N_SIZE), iterNum, tabuMem, darp, curRoutes, moves, vc)
            end
            @timeit to "localsearch" begin
                bestTid = local_search(Val(N), Val(N_SIZE), darp, N_SIZE, scores, moves, curRoutes, curOptRoutes, to, vc)
            end
        end
        # use bestTid to update the cur values
        # DO we really want to always applY?????
        bestMove = moves[bestTid]
        newRoutes, newRVals, newOptRoutes = apply_move(valN, darp, bestMove, curRoutes, curRVals, curOptRoutes, vc)

        # add move to frequency
        if !haskey(attributeFrequency, (bestMove.i, bestMove.k2))
            attributeFrequency[(bestMove.i, bestMove.k2)] = 0
        end
        attributeFrequency[(bestMove.i, bestMove.k2)] += 1

        if newOptRoutes.Val < bestOptRoutes.Val
            bestRoutes = newRoutes
            bestRVals = newRVals
            bestOptRoutes = newOptRoutes
            vc = randomize_coefficients(vc, darp.nR)
        end

        if bestOptRoutes.Val < 0
            println("Negative OptVal: $(bestOptRoutes.Val)")
            println(bestOptRoutes)
            println("Stopping")
            break
        end

        optValuesLog[iterNum] = bestOptRoutes.Val

        # use the new ones as current and continue
        curRoutes, curRVals, curOptRoutes = newRoutes, newRVals, newOptRoutes
        improved = percentage_improved(baseVal, bestOptRoutes.Val)
        gap = bestOptRoutes.Val - bks
        println("$(iterNum) | gap=$(gap) | Tt=$(vc.THETA) | tabuMissCount=$(tabuMissCount) | best=$(bestOptRoutes.Val) | cur=$(curOptRoutes.Val)")
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

        iterNum += 1
    end
    return bestRoutes, bestOptRoutes
end

function local_search(valN::Val{N}, ::Val{NSIZE}, darp::DARP, N_SIZE::Int, scores::MVector{NSIZE}, moves::MVector{NSIZE,MoveParams}, baseRoute::Routes{N}, baseOptRoutes::OptRoutes, to::TimerOutput, vc::VoilationCoefficients) where {N,NSIZE}
    # use each allocated space and do the work.....
    Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        optRoute::OptRoutes = calc_opt_incr(valN, darp, baseRoute, move, baseOptRoutes, vc)
        scores[tid] = optRoute.Val
    end
    _, minTid = findmin(scores)
    return minTid
end
