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
    requestDict = Dict{Int64,Request}([])
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
    depotTW = (depotLine[6], depotLine[7])

    T = 1440 # end of planning horizon

    # only read half lines, project for inbound
    for idx in 3:3+nR-1
        pickupIdx = idx
        dropoffIdx = idx + nR
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
        isPickupCritical = false
        if pe != 0.0 && pl != T
            isPickupCritical = true
        end

        criticalTW::Tuple{Float64,Float64} = (de, dl)
        if isPickupCritical
            criticalTW = (pe, pl)
        end

        request = Request(i, pPickup, pDropoff, travel_time(pPickup, pDropoff),
            max_ride_time,
            (pe, pl), (de, dl),
            pd, dd, pq, dq,
            criticalTW)
        requestDict[request.id] = request
        push!(requests, request)
    end
    println("Request size = $(length(requests))")
    return requests, requestDict, depotPoint, depotTW, nR, m, Q, max_route_duration
end

function travel_time(pone::Point, ptwo::Point)
    Float64
    return sqrt((ptwo.x - pone.x)^2 + (ptwo.y - pone.y)^2)
end

# reqs, depotPoint, n, m = parseFile("/Users/raghuveernaraharisetti/mscs/dail-a-ride/DARP-Multi-CPU/benchmark-data/chairedistributique/data/darp/tabu/pr01")
