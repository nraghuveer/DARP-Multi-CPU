export JULIA_NUM_THREADS=8
julia src/test_runner.jl --statsfile $1.csv

export JULIA_NUM_THREADS=4
julia src/test_runner.jl --statsfile $1.csv

export JULIA_NUM_THREADS=2
julia src/test_runner.jl --statsfile $1.csv

export JULIA_NUM_THREADS=1
julia src/test_runner.jl --statsfile $1.csv
