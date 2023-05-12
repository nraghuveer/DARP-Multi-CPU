using Base.Threads
using Dates

# end is reserved keyword!
function ts_diff(start::Dates.DateTime, endDt::Dates.DateTime)
    Float64
    return Dates.datetime2unix(endDt) - Dates.datetime2unix(start)
end

function percentage_improved(old::Float64, new::Float64)
    Float64
    if old < new
        return 0.0
    end
    decrease = (new * 100) / old
    return 100 - decrease
end

function freeMem()
    return Sys.free_memory() / 2^20
end

mutable struct DARPStat
    nThreads::Int64
    file::String
    total_iterations::Int64
    n_size::Int64
    time_initSolution::Float64
    time_localSearch::Float64
    time_total::Float64
    bestOptFnValue::Float64
    version::String
    function DARPStat(file::String, n_size::Int64, version::String)
        return new(Threads.nthreads(), file, 0, n_size, 0.0, 0.0, 0.0, 0.0, version)
    end
end

function reduceTabuTenure(cur::Float64, minValue::Float64, delta::Float64)
    Float64
    tt = max(minValue, cur - (cur * delta))
    # tt = floor(Int64, tt)
    # return Float64(tt)
    return tt
end

function increaseTabuTenure(cur::Float64, maxValue::Float64, delta::Float64)
    Float64
    tt = min(maxValue, cur + (cur * delta))
    # tt = ceil(Int64, tt)
    # return Float64(tt)
    return tt
end

