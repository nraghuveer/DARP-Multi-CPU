include("darp.jl")
include("optimization_fn.jl")
include("local_search_kernel.jl")
include("utils.jl")
include("sampling.jl")
using Base.Threads
using Dates
using ArgParse
using CSV
using TimerOutputs
using Test


# TODO: Tighten bounds for each route

const to = TimerOutput()

function run(darp::DARP, N_SIZE::Int64, stats::DARPStat, bks::Float64, mrt::Int64, enableTimerLogs::Bool=true)
    println("Running on $(Threads.nthreads()) threads")
    nR = darp.nR
    if !enableTimerLogs
        disable_timer!(to)
    end

    program_start = now()
    println("Using nR=$(nR) | nV=$(darp.nV) | Q=$(darp.Q)")
    println("Using N_SIZE=$(N_SIZE)")
    println("Using BKS=$(bks)")
    println("Using MRT=$(mrt)")
    println("Free Memory $(freeMem())")
    println("Starndard Cost = $(darp.standardCost)")
    total_iterations = trunc(Int64, 0.9 * nR)

    INIT_SCALING_FACTOR = 15
    valN = Val(darp.MAX_ROUTE_SIZE)
    temp = Dict(k => Vector{Int64}([]) for k in darp.vehicles)
    allBestRoutes = Dict(i => copy(temp) for i in 1:(N_SIZE*INIT_SCALING_FACTOR))
    allBestOptRoutesValues = Dict(i => Inf for i in 1:(N_SIZE*INIT_SCALING_FACTOR))

    va = VoilationVariables(darp.nR, darp.nV)

    @timeit to "init" begin
        Threads.@threads for i in 1:(N_SIZE*INIT_SCALING_FACTOR)
            toOuter = TimerOutput()
            @timeit toOuter "init$(i)" begin
                to2 = TimerOutput()
                @timeit to2 "genRoute" begin
                    to3 = TimerOutput()
                    curRoutes = generate_random_route!(valN, darp, to3)
                end
                @timeit to2 "rvals" begin
                    to3 = TimerOutput()
                    rvals = Dict(k => route_values!(valN, darp, curRoutes[k], to3) for k in keys(curRoutes))
                    merge!(to2, to3, tree_point=["rvals"])
                end
                @timeit to2 "calcOptFull" begin
                    optRoutes = calc_opt_full(valN, darp, rvals, curRoutes, va)
                end

                allBestRoutes[i] = curRoutes
                if optRoutes.feasible
                    allBestOptRoutesValues[i] = optRoutes.Val
                else
                    allBestOptRoutesValues[i] = Inf
                end

                if enableTimerLogs
                    merge!(toOuter, to2, tree_point=["init$(i)"])
                end
            end

            if enableTimerLogs
                merge!(to, toOuter, tree_point=["init"])
            end
        end
    end
    _, minTid = findmin(allBestOptRoutesValues)
    println("Best Value for InitRoutes = $(allBestOptRoutesValues[minTid])")
    bestRoutes = allBestRoutes[minTid]

    # convert vector routes to MVectors
    initRoutes::Routes{darp.MAX_ROUTE_SIZE} = Dict(k => copyVectorRoute!(valN, darp, bestRoutes[k], emptyRoute(darp)) for k in darp.vehicles)
    println("Done init route generation")

    search_start = now()
    # build init routes
    @timeit to "search" begin
        routesSolution, optRoutesSolution = search(Val(darp.MAX_ROUTE_SIZE), darp, bks, mrt, N_SIZE, initRoutes, va, stats, to)
        println("######################")
        printRoutes(routesSolution, darp)
        println("######################")
        println("Opt Value = $(optRoutesSolution.Val)")
        stats.bestOptFnValue = optRoutesSolution.Val
    end
    stats.time_localSearch = ts_diff(search_start, now())
    stats.time_total = ts_diff(program_start, now())
    println("Search Time => $(stats.time_localSearch)")
    println("Total Time => $(stats.time_total)")
    if enableTimerLogs
        show(to)
        println("\n")
    else
        enable_timer!(to)
    end
    # println("")
    return stats
end
