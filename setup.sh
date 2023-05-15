wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.1-linux-x86_64.tar.gz
tar zxvf julia-1.8.1-linux-x86_64.tar.gz

export PATH="$PATH:/root/julia-1.8.1/bin/"
git clone https://github.com/nraghuveer/DARP-Multi-CPU.git

cd DARP-Multi-CPU
mkdir test-runs
mkdir test-runs/bks
mkdir test-runs/mrt
mkdir logs
mkdir logs/bks
mkdir logs/mrt

julia -e 'using Pkg; Pkg.add("StatsBase"); Pkg.add("Random"); Pkg.add("CSV"); Pkg.add("ArgParse"); Pkg.add("StaticArrays"); Pkg.add("Distributions"); Pkg.add("TimerOutputs")'

sudo apt update
sudo apt install python-pandas

echo "Done......"

