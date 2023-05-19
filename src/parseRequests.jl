const DROPOFF_ALPHA = 1.5
# Constants for reading data line
const IDX = 1
const SRC_POINT_X = 2
const SRC_POINT_Y = 3
const DST_POINT_X = 4
const DST_POINT_Y = 5
const DRT = 6
const MRT = 7
const PICKUP_OR_DROPOFF_TIME = 8
const ISPICK_TIME = 9

struct Point
    x::Float64
    y::Float64
    Point(x, y) = new(x, y)
end

const TW = Tuple{Float64,Float64}

struct Request
    id::Int64
    src::Point
    dst::Point
    direct_ride_time::Float64
    max_ride_time::Float64
    pickup_tw::TW
    dropoff_tw::TW
    pickup_servicetime::Float64
    dropoff_servicetime::Float64
    pickup_load::Int64
    dropoff_load::Int64
    criticalTW::TW
end

function request_from_dataline(line::AbstractString)
    parts = split(line, "\t")
    parts = filter(part -> part != "", parts)
    # the parts should ateleast of size 9
    if length(parts) < 9
        return nothing
    end

    time = parse(Float64, parts[PICKUP_OR_DROPOFF_TIME])
    drt = parse(Float64, parts[DRT])
    mrt = parse(Float64, parts[MRT])
    return Request(1,
        parse(Int64, parts[IDX]),
        Point(parse(Int64, parts[SRC_POINT_X]), parse(Int64, parts[SRC_POINT_Y])),
        Point(parse(Int64, parts[DST_POINT_X]), parse(Int64, parts[DST_POINT_Y])),
        drt,
        mrt,
        time,
        time + (DROPOFF_ALPHA * drt),
        Bool(parse(Int8, parts[ISPICK_TIME]))
    )
end


function parseData(noofCustomers::Int64,
    serviceDuration::Int64, areaOfService::Int64)
    filepath = "data/Temportal-DS/nCustomers_$(noofCustomers)/Temporal_SD$(serviceDuration)hrs_SA$(areaOfService)km.txt"
    println("source=$(filepath)")
    println("######################################################")
    requests = Request[]
    filelines = readlines(filepath)

    for line in filelines
        req = request_from_dataline(line)
        if isnothing(req)
            println("nothing")
            continue
        end
        push!(requests, req)
    end

    return requests
end

