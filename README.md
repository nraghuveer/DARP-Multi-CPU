# DARP-Multi-CPU
Granular Tabu Search implementation of DARP for the single/multi CPU in Julia

## Steps to Run
1. Install julia
2. Enter into julia shell by running command `julia`
3. Run below code

```
use Pkg
Pkg.add("StatsBase")
Pkg.add("Random")
Pkg.add("DateTime")
Pkg.add("ArgParse")
```

This is same as pip install, I still couldn't figure out how to generate env files
for julia env shells and define deps...Might not actually need it since we use
limited non-std packages

4. Export env variable (configure it)

`export JULIA_NUM_THREADS=4`

This makes Julia runtime to consume only 4 CPU cores

5. Run the program

```
julia src/main.jl
```

## Breakdown of log line

![log-line-breakdown](images/log-line-breakdown.png)


## TODO
1. Diversification
2. Intensification
