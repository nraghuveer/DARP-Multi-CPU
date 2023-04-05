include("darp.jl")
include("parseRequests.jl")
using StaticArrays
using TimerOutputs

const RVAL = Dict{Int64,Float64}
const RVALS = NTuple{5,Dict{Int64,Float64}}
const RMAP = Dict{Int64,Int64}
const SRVALS = Tuple{RMAP,NTuple{5,Vector{Float64}}}


function route_values(route::AbstractArray{Int64}, darp::DARP)
    SRVALS
    # dictionary/mapping for index to position in route
    n = length(route)

    routeMaps::Dict{Int64,Int64} = Dict{Int64,Int64}(darp.start_depot => 1)
    A = zeros(n)
    w = zeros(n)
    B = zeros(n)
    D = zeros(n)
    y = zeros(n)

    for index in eachindex(route)
        if index <= 1
            continue
        end
        # update routeMaps
        prev = route[index-1]
        cur = route[index]
        routeMaps[cur] = index
        prev_index = routeMaps[prev]
        cur_index = routeMaps[cur]

        A[index] = D[prev_index] + travel_time(darp, prev, cur)
        B[index] = A[cur_index]
        D[index] = B[cur_index] + darp.d[cur]
        w[index] = B[cur_index] - A[cur_index]
        y[index] = y[prev_index] + darp.q[cur]
    end

    return routeMaps, (A, w, B, D, y)
end

function calc_opt(darp::DARP, rvalues::Dict{Int64,SRVALS}, routes::Route)
    c = 0.0
    q = 0.0
    d = 0.0
    w = 0.0
    t = 0.0

    for k in keys(routes)
        routeMaps::RMAP = rvalues[k][1]
        rrvalues = rvalues[k][2]

        end_depot_index = routeMaps[darp.end_depot]
        duration_of_route = rrvalues[4][end_depot_index]

        # duration of route
        d += max(duration_of_route - darp.T_route, 0)
        prev = routes[k][1]
        prev_index = routeMaps[prev]

        for cur in routes[k][2:end]
            cur_index = routeMaps[cur]
            # max cap in route
            q = max(rrvalues[5][cur_index] - darp.Q, 0)
            # cost of travel
            c += travel_time(darp, prev, cur)
            prev = cur
            if cur == darp.end_depot || cur == darp.start_depot || cur <= 0
                continue
            end
            c -= travel_time(darp, cur, -cur)

            cur_dropoff_index = routeMaps[-cur]
            Bi_pickup = rrvalues[3][cur_index]
            Bi_dropoff = rrvalues[3][cur_dropoff_index]
            _, li_pickup = darp.tw[cur]
            _, li_dropoff = darp.tw[-cur]
            # late_quantity
            w += max(Bi_pickup - li_pickup, 0) + max(Bi_dropoff - li_dropoff, 0)
            # ride time
            t += max(Bi_dropoff - Bi_pickup, 0)
        end
    end
    return (c + q + d + w + t) / 1.0
end
