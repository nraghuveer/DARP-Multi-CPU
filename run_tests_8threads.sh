for var in "${@:2}"
do
    export JULIA_NUM_THREADS=$var
    julia src/test_runner.jl --statsfile $1.csv
done
