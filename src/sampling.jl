# helper functions for sampling - specific to this algorithm
include("darp.jl")
using StatsBase
using Test
using Random

function generate_random_vectorRoutes(darp::DARP, to::TimerOutput)
    Dict{Int64,Array{Int64}}
    nR = darp.nR
    routes = Dict(k => [darp.start_depot] for k in darp.vehicles)

    @timeit to "sampling" begin

        requests = collect(1:nR)
        sort!(requests, by=r -> return darp.requestsDict[r].criticalTW[1])
        # dont replace requests once picked
        randomized_requests = StatsBase.sample(requests, darp.requestWeights, nR, replace=false, ordered=true)
        # vehicles needs to picked with replace=true
        randomized_ks = StatsBase.sample(darp.vehicles, darp.vehicleWeights, nR, replace=true, ordered=false)
    end

    for idx in 1:nR
        req = randomized_requests[idx]
        k = randomized_ks[idx]
        l = length(routes[k])
        @timeit to "random" begin
            p1 = rand(2:l+1)
            p2 = rand(p1+1:l+2)
        end
        @timeit to "insertion" begin
            insert!(routes[k], p1, req)
            insert!(routes[k], p2, -req)
        end
    end

    for k in darp.vehicles
        append!(routes[k], darp.end_depot)
    end

    return routes
end

function generate_random_route!(::Val{N}, darp::DARP, to2::TimerOutput) where {N}
    return generate_random_vectorRoutes(darp, to2)
end
