import os

directory_path = './benchmark-data/chairedistributique/data/darp/tabu/'

def generate_pr_block(prNum, mrt, runs, threads):
    filename = f'pr' + str(prNum).zfill(2)
    lines = []
    for i in range(1, runs+1):
        outputfileName = f"""test-runs/mrt/$1-{prNum}.{i}"""
        lines.append(f"""filename="test-runs/mrt/$1-{prNum}.{i}.csv"\n""")
        lines.append(f"""if [ ! -e "$filename"  ]\n""")
        lines.append("then\n")
        lines.append(f"    ./runv2.sh {outputfileName} {filename} $2 0 {mrt} {threads} >> logs/mrt/$1.txt\n")
        lines.append("fi\n")
        lines.append(f"echo '{prNum}.{i}'\n")
        lines.append("\n")
        # lines.append(f"echo '{prNum}.{i}'\n")
    return lines

def main(outputfile, threads, sample_size, datasets_size, mrt):

    lines = ["#!/bin/bash\n"]
    for i in range(datasets_size, 0, -1):
        filename = f'pr' + str(i).zfill(2)
        i_lines = generate_pr_block(i, mrt, sample_size, threads)
        lines.extend(i_lines)
        lines.append("\n")

    with open(outputfile, 'w') as file:
        for line in lines:
            file.write(line)
    print('done')

outputfile = input("Output filename: ")
outputfile = outputfile + '.sh'
threads = input("Thread config: ")
sample_size_str = input("Sample Size: ")
sample_size = int(sample_size_str)
datasize_str = input("# DataSets: ")
datasets = int(datasize_str)
mrt = input("Max RunTime: ")
main(outputfile, threads, sample_size, datasets, int(mrt))


