# DARP-Multi-CPU
Granular Tabu Search implementation of DARP for the single/multi CPU in Julia

## Steps to Run
1. Install julia
2. Export env variable (configure it)

`export JULIA_NUM_THREADS=4`

This makes Julia runtime to consume only 4 CPU cores


3. Run

```
julia src/main.jl
```

## Breakdown of log line

![log-line-breakdown](images/log-line-breakdown.png)