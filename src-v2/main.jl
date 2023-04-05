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

function run(nR::Int64, sd::Int64, aos::Int64, nV::Int64, Q::Int64, enableTimerLogs::Bool=true)
    println("====================================================================")
    println("Running on $(Threads.nthreads()) threads")

    if !enableTimerLogs
        disable_timer!(to)
    end

    @timeit to "darpInit" begin
        stats = DARPStat(nR, sd, aos, nV, Q)
        stats.version = "memoptimization"
        darp = DARP(nR, sd, aos, nV, Q, stats)
    end

    start_dt = now()
    N_SIZE = trunc(Int64, 0.5 * nR)
    println("Using N_SIZE=$(N_SIZE)")
    println("Free Memory $(freeMem())")
    total_iterations = trunc(Int64, 0.9 * nR)
    stats.localSearchIterations = total_iterations
    stats.searchMoveSize = N_SIZE

    valN = Val(darp.MAX_ROUTE_SIZE)
    bestScore = Inf
    bestRoutes = Dict(k => [] for k in darp.vehicles)

    @timeit to "init" begin
        Threads.@threads for i in 1:N_SIZE
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
                    optRoutes = calc_opt_full(valN, darp, rvals, curRoutes)
                end
                if optRoutes.Val <= bestScore
                    bestScore = optRoutes.Val
                    bestRoutes = curRoutes
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
    println("Done init route generation")

    # convert vector routes to MVectors
    initRoutes::Routes{darp.MAX_ROUTE_SIZE} = Dict(k => copyVectorRoute!(valN, darp, bestRoutes[k], emptyRoute(darp)) for k in darp.vehicles)
    # build init routes
    GC.gc(true)
    @timeit to "search" begin
        search(Val(darp.MAX_ROUTE_SIZE), darp, total_iterations, N_SIZE, initRoutes, stats, to)
    end
    stats.time_total = ts_diff(start_dt, now())
    println("Total Time => $(stats.time_total)")
    show(to)
    if !enableTimerLogs
        enable_timer!(to)
    end
    # println("")
    return stats
end

function main()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--nR"
        help = "number of requests"
        arg_type = Int64
        default = 50
        "--sd"
        help = "service duration"
        arg_type = Int64
        default = 2
        "--aos"
        help = "area of service in Kms"
        arg_type = Int64
        default = 10
        "--nV"
        help = "number of vehicles"
        arg_type = Int64
        default = 10
        "--Q"
        help = "vehicle capacity"
        arg_type = Int64
        default = 5
        "--statsfile"
        help = "stats outputfilename"
        arg_type = String
        default = Dates.format(now(), "mm-dd-yyyy HH:MM:SS")
    end
    args = parse_args(s)
    stats = run(args["nR"], args["sd"], args["aos"], args["nV"], args["Q"])
    CSV.write(join([args["statsfile"], "_", string(Threads.nthreads()), ".csv"]),
        [stats])
    show(to)
end

# main()
