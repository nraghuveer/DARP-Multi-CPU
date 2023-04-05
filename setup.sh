wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.1-linux-x86_64.tar.gz
tar zxvf julia-1.8.1-linux-x86_64.tar.gz

export PATH="$PATH:/root/julia-1.8.1/bin/"
git clone https://github.com/nraghuveer/DARP-Multi-CPU.git

cd DARP-Multi-CPU
chmod +x run_tests_adv.sh

julia -e 'using Pkg; Pkg.add("StatsBase"); Pkg.add("Random"); Pkg.add("CSV"); Pkg.add("ArgParse"); Pkg.add("StaticArrays")'

echo "Done......"

