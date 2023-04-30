for var in "${@:4}"
do
    export JULIA_NUM_THREADS=$var
    julia src/test_runner.jl --statsfile $1.csv --datafile $2 --nsize $3
done
