include("main.jl")
include("utils.jl")
using Base
using CSV
using ArgParse

# The idea is to run the dataset with different thread configs

requests = [50, 350, 500, 650, 1000]
area_of_service = [10]
service_duration = [2]

function run_tests()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--statsfile"
        help = "output file for stats"
        arg_type = String
        required = true
        default = Dates.format(now(), "mm-dd-yyyy HH:MM:SS")
    end
    args = parse_args(s)
    all_stats::Array{DARPStat} = []
    for p in Base.product(requests, service_duration, area_of_service)
        nR, sd, aos = p
        nV = trunc(Int64, nR / 10)
        Q = 10
        stats = run(nR, sd, aos, nV, Q)
        push!(all_stats, stats)
    end

    CSV.write(args["statsfile"], all_stats, append=true)
end

run_tests()