include("darp.jl")
include("construction_kernel.jl")
include("optimization_fn.jl")
include("local_search_kernel.jl")
include("utils.jl")
using Base.Threads
using Dates
using ArgParse
using CSV

# TODO: Tighten bounds for each route

function run(nR::Int64, sd::Int64, aos::Int64, nV::Int64, Q::Int64)
    DARPStat
    println("====================================================================")
    start_dt = now()
    println("Running on $(Threads.nthreads()) threads")
    # darp = DARP(500, 2, 10, 5, 1)
    stats = DARPStat(nR, sd, aos, nV, Q)
    darp = DARP(nR, sd, aos, nV, Q, stats)
    N_SIZE = 0.75 * darp.nR
    N_SIZE = trunc(Int64, N_SIZE)
    total_iterations = darp.nR * 1
    stats.localSearchIterations = total_iterations
    stats.searchMoveSize = N_SIZE

    routes = fill(Route(), N_SIZE)
    scores = fill(floatmin(Float64), N_SIZE)
    Threads.@threads for i in 1:N_SIZE
        cur::Route = generate(10, darp.requests, darp.nR, darp.nV)
        scores[i] = calc_optimization_val(darp, cur)
        routes[i] = cur
    end
    _, idx = findmin(scores)
    init_route_complete_dt = now()
    stats.time_initSolution = ts_diff(start_dt, init_route_complete_dt)
    println("Init solution ($(N_SIZE) size) took => $(stats.time_initSolution)")
    local_search(darp, total_iterations, N_SIZE, routes[idx], stats)
    local_search_completed_dt = now()
    stats.time_localSearch = ts_diff(init_route_complete_dt, local_search_completed_dt)
    println("Local Search ($(total_iterations) iterations) took => $(stats.time_localSearch)")
    stats.time_total = ts_diff(start_dt, local_search_completed_dt)
    println("Total Time => $(stats.time_total)")
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
    println("Done!")
end

# main()