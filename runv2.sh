for var in "${@:5}"
do
    export JULIA_NUM_THREADS=$var
    julia src/test_runner.jl --statsfile $1.csv --datafile $2 --nsize $3 --bks $4
done
