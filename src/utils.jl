using Dates

# end is reserved keyword!
function ts_diff(start::Dates.DateTime, endDt::Dates.DateTime) Float64
    return Dates.datetime2unix(endDt) - Dates.datetime2unix(start)
end