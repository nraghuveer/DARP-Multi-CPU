include("darp.jl")
include("optimization_fn.jl")
include("local_search_kernel.jl")
include("utils.jl")
include("sampling.jl")
include("construction_kernel.jl")
using Base.Threads
using Dates
using ArgParse
using CSV
using TimerOutputs


# TODO: Tighten bounds for each route

const to = TimerOutput()

function run(nR::Int64, sd::Int64, aos::Int64, nV::Int64, Q::Int64)
    println("====================================================================")
    println("Running on $(Threads.nthreads()) threads")
    stats = DARPStat(nR, sd, aos, nV, Q)
    stats.version = "staticarrays"
    darp = DARP(nR, sd, aos, nV, Q, stats)

    start_dt = now()
    N_SIZE = trunc(Int64, 0.5 * nR)
    println("Using N_SIZE=$(N_SIZE)")
    total_iterations = trunc(Int64, 0.6 * nR)
    stats.localSearchIterations = total_iterations
    stats.searchMoveSize = N_SIZE

    routes = fill(Route(), N_SIZE)
    scores = fill(floatmin(Float64), N_SIZE)
    !disable_timer!(to)
    Threads.@threads for i in 1:N_SIZE
        cur::Route = generate(darp.nR, darp.nV)
        curRoute::Route = Dict(k => [[darp.start_depot]; cur[k]; [darp.end_depot]]
                               for k in keys(cur))
        rvalues = Dict(k => route_values(curRoute[k], darp) for k in keys(curRoute))
        scores[i] = calc_opt(darp, rvalues, curRoute)
        routes[i] = curRoute
    end
    enable_timer!(to)
    println("After init")

    _, idx = findmin(scores)
    local_search(darp, total_iterations, N_SIZE, routes[idx], stats, to)
    stats.time_total = ts_diff(start_dt, now())
    println("Total Time => $(stats.time_total)")
    # show(to)
    println("")
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
