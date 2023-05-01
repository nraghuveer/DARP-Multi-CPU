include("parseRequests.jl")

VERTEX_IDX = 1
X_IDX = 2
Y_IDX = 3
D_IDX = 4
Q_IDX = 5
E_IDX = 6
Y_IDX = 7

function lineToFloatParts(line::String, size::Int64)
    Array{Float64}
    parts = split(line, " ")
    res = [0.0 for i in 1:size]
    i = 1
    for part in parts
        part = strip(part)
        if isempty(part)
            continue
        end
        res[i] = parse(Float64, part)
        i += 1
    end
    return res
end

function parseFile(path::String)
    requests = Request[]
    filelines = readlines(path)
    header = lineToFloatParts(filelines[1], 5)
    depotLine = lineToFloatParts(filelines[2], 7)

    # Extract header and depot fields``
    m = trunc(Int64, header[1])
    n = trunc(Int64, header[2])
    nR = trunc(Int64, n / 2)
    max_route_duration = trunc(Int64, header[3])
    Q = trunc(Int64, header[4])
    max_ride_time = trunc(Int64, header[5])
    depotPoint = Point(depotLine[2], depotLine[3])

    # only read half lines, project for inbound
    for idx in 0:trunc(Int64, nR)
        pickupIdx = idx + 2
        dropoffIdx = (idx + nR) + 2
        pickupParts = lineToFloatParts(filelines[pickupIdx], 7)
        dropoffParts = lineToFloatParts(filelines[dropoffIdx], 7)
        i::Int64 = trunc(Int64, pickupParts[1])

        px::Float64 = pickupParts[2]
        py::Float64 = pickupParts[3]
        pd::Float64 = pickupParts[4]
        pq::Int64 = trunc(Int64, pickupParts[5])
        pe::Float64 = pickupParts[6]
        pl::Float64 = pickupParts[7]
        dx::Float64 = dropoffParts[2]
        dy::Float64 = dropoffParts[3]
        dd::Float64 = dropoffParts[4]
        dq::Int64 = trunc(Int64, dropoffParts[5])
        de::Float64 = dropoffParts[6]
        dl::Float64 = dropoffParts[7]

        pPickup::Point = Point(px, py)
        pDropoff::Point = Point(dx, dy)
        request = Request(i, pPickup, pDropoff, travel_time(pPickup, pDropoff),
            max_ride_time,
            (pe, pl), (de, dl), pd, dd, pq, dq)
        push!(requests, request)
    end
    println(length(requests))
    return requests, depotPoint, nR, m, Q, max_route_duration
end

function travel_time(pone::Point, ptwo::Point)
    Float64
    return (abs(pone.x - ptwo.x) + abs(pone.y - ptwo.y))
end

# reqs, depotPoint, n, m = parseFile("/Users/raghuveernaraharisetti/mscs/dail-a-ride/DARP-Multi-CPU/benchmark-data/chairedistributique/data/darp/tabu/pr01")
