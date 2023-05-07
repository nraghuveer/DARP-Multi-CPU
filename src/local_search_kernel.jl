import Base.Threads
import StatsBase
import Random
import StaticArrays
import TimerOutputs

include("darp.jl")
include("utils.jl")
const Int = Int64

Tt_Delta = 0.7
NIT = 3

function search(valN::Val{N}, darp::DARP, bks::Float64, N_SIZE::Int, initRoutes::Routes, stats::DARPStat, to::TimerOutput) where {N}
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
    bestRVals::Dict{Int64,RVals{N}} = curRVals

    baseVal = curOptRoutes.Val

    # Tabu Tenure => number of iteration for which a move is marked a tabu which forbids it repeating
    # This is Dynamic tabu tenure, which means it value is based on the object function value
    Tt::Float64 = 1.0
    # we need to know if the value increased or decreased in last NIT number of times
    # if value is true, it is increased, else decreased
    optValHistory = Dict{Int64,Bool}([])

    iterNum = 1
    while true
        @timeit to "localsearch#$(iterNum)" begin
            @timeit to "randomMove" begin
                tabuMissCount = generate_random_moves(valN, Val(N_SIZE), iterNum, tabuMem, Tt, darp, curRoutes, moves)
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

            optValHistory[iterNum] = true
        else
            optValHistory[iterNum] = false
        end

        # use the new ones as current and continue
        curRoutes, curRVals, curOptRoutes = newRoutes, newRVals, newOptRoutes
        improved = percentage_improved(baseVal, bestOptRoutes.Val)
        gap = bestOptRoutes.Val - bks
        println("$(iterNum) | gap=$(gap) | Tt=$(Tt) | tabuMissCount=$(tabuMissCount) | best=$(bestOptRoutes.Val) | cur=$(curOptRoutes.Val)")
        println("Free Memory $(freeMem())")
        if gap <= 0
            println("Total Iterations: $(iterNum)")
            stats.total_iterations = iterNum
            break
        end

        history = Array{Bool}([])
        if iterNum >= NIT
            for oldIterNum = iterNum-NIT+1:iterNum
                push!(history, optValHistory[oldIterNum])
            end
        end

        if any(history)
            Tt = max(1.0, Tt - ceil(Tt_Delta * Tt))
            println("Reducing Tabu Tenure = ", Tt)
        else
            Tt = Tt + ceil(Tt_Delta * Tt)
            println("Increasing Tabu Tenure = ", Tt)
        end

        iterNum += 1
    end
end

function local_search(valN::Val{N}, ::Val{NSIZE}, darp::DARP, N_SIZE::Int, scores::MVector{NSIZE}, moves::MVector{NSIZE,MoveParams}, baseRoute::Routes{N}, baseOptRoutes::OptRoutes, to::TimerOutput) where {N,NSIZE}
    # use each allocated space and do the work.....
    Threads.@threads for tid in 1:N_SIZE
        move = moves[tid]
        optRoute::OptRoutes = calc_opt_incr(valN, darp, baseRoute, move, baseOptRoutes)
        scores[tid] = optRoute.Val
    end
    _, minTid = findmin(scores)
    return minTid
end
