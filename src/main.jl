include("darp.jl")
include("construction_kernel.jl")
include("optimization_fn.jl")
include("local_search_kernel.jl")
include("utils.jl")
using BenchmarkTools
using Base.Threads

# TODO: Tighten bounds for each route

function main()
    start_dt = now()
    println("Running on $(Threads.nthreads()) threads")
    darp = DARP(500, 2, 10, 5, 1)
    N_SIZE = 0.75 * darp.nR
    N_SIZE = trunc(Int64, N_SIZE)
    total_iterations = darp.nR * 10

    routes = fill(Route(), N_SIZE)
    scores = fill(floatmin(Float64), N_SIZE)
    Threads.@threads for i in 1:N_SIZE
        cur::Route = generate(10, darp.requests, darp.nR, darp.nV)
        scores[i] = calc_optimization_val(darp, cur)
        routes[i] = cur
    end
    _, idx = findmin(scores)
    init_route_complete_dt = now()
    println("Init solution ($(N_SIZE) size) took => $(ts_diff(start_dt, init_route_complete_dt))")
    local_search(darp, total_iterations, N_SIZE, routes[idx])
    local_search_completed_dt = now()
    println("Local Search ($(total_iterations) iterations) took => $(ts_diff(init_route_complete_dt, local_search_completed_dt))")
    println("Total Time => $(ts_diff(local_search_completed_dt, start_dt))")
end

main()