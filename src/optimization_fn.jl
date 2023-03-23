include("darp.jl")
include("parseRequests.jl")
using TimerOutputs

const RVAL = Dict{Int64,Float64}
const RVALS = NTuple{5,Dict{Int64,Float64}}

# excepts each routes start and end depot to be actual start and deport nodes
function route_values(route::Array{Int64}, darp::DARP)
    RVALS
    A = RVAL([0 => 0])
    w = RVAL([0 => 0])
    B = RVAL([0 => 0])
    D = RVAL([0 => 0])
    y = RVAL([0 => 0])

    for (prev, i) in zip(route, route[2:end])
        A[i] = D[prev] + travel_time(darp, prev, i)
        B[i] = A[i]
        D[i] = B[i] + darp.d[i]
        w[i] = B[i] - A[i]
        y[i] = y[prev] + darp.q[i]
    end

    return A, w, B, D, y
end

function calc_opt(tid::Int64, darp::DARP, rvalues::Dict{Int64,RVALS}, routes::Route, to::TimerOutput)
    c = 0.0
    q = 0.0
    d = 0.0
    w = 0.0
    t = 0.0

    for k in keys(routes)
        rrvalues = rvalues[k]
        duration_of_route = rrvalues[4][darp.end_depot]
        # duration of route
        d += max(duration_of_route - darp.T_route, 0)
        prev = routes[k][1]
        for i in routes[k][2:end]
            # max cap in route
            q = max(rrvalues[5][i] - darp.Q, 0)
            # cost of travel
            c += travel_time(darp, prev, i)
            prev = i
            if i == darp.end_depot || i == darp.start_depot || i <= 0
                continue
            end
            c -= travel_time(darp, i, -i)

            Bi_pickup = rrvalues[3][i]
            Bi_dropoff = rrvalues[3][-i]
            _, li_pickup = darp.tw[i]
            _, li_dropoff = darp.tw[-i]
            # late_quantity
            w += max(Bi_pickup - li_pickup, 0) + max(Bi_dropoff - li_dropoff, 0)
            # ride time
            t += Bi_dropoff - Bi_pickup
        end
    end
    return (c + q + d + w + t) / 1.0
end
