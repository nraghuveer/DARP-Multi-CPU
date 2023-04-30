include("main.jl")
include("utils.jl")
using Base
using CSV
using ArgParse

function run_tests()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--statsfile"
        help = "output file for stats"
        arg_type = String
        required = true
        default = Dates.format(now(), "mm-dd-yyyy HH:MM:SS")
    end
    @add_arg_table s begin
        "--datafile"
        help = "data file suffix"
        arg_type = String
        required = true
        default = "pr01"
    end
    @add_arg_table s begin
        "--nsize"
        help = "neighborhood size"
        arg_type = Int64
        required = true
        default = 25
    end
    args = parse_args(s)
    all_stats::Array{DARPStat} = []
    stats = DARPStat(args["datafile"], args["nsize"], "2.0")
    darp = DARP(args["datafile"], stats)
    run(darp, args["nsize"], stats, false)
    push!(all_stats, stats)
    CSV.write(args["statsfile"], all_stats, append=true)
end

run_tests()
