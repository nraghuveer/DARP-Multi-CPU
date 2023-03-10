using Base.Threads
using Dates

# end is reserved keyword!
function ts_diff(start::Dates.DateTime, endDt::Dates.DateTime) Float64
    return Dates.datetime2unix(endDt) - Dates.datetime2unix(start)
end


mutable struct DARPStat
    nThreads::Int64
    nR::Int64
    sd::Int64
    aos::Int64
    nV::Int64
    Q::Int64
    best_improvement::Float64
    localSearchIterations::Int64
    searchMoveSize::Int64
    time_initSolution::Float64
    time_localSearch::Float64
    time_total::Float64
    # improvements::Array{Float64}
    # time_localSearchMoves::Array{Float64}
    function DARPStat(nR::Int64, sd::Int64, aos::Int64, nV::Int64, Q::Int64)
        return new(Threads.nthreads(), nR, sd, aos, nV, Q, 0.0, 0, 0, 0.0, 0.0, 0.0)
    end
end