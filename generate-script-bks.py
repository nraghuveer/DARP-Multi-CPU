import os
import math
from typing import Dict

directory_path = './benchmark-data/chairedistributique/data/darp/tabu/'

# initialize an empty dictionary to store the results
bks_dict: Dict[int, int] = dict()
nR_dict: Dict[int, int] = dict()
nV_dict: Dict[int, int] = dict()

def generate_pr_block(prNum, nR, nV, bks, runs, threads):
    filename = f'pr' + str(prNum).zfill(2)
    lines = []
    nsize_1 = int(math.floor(nR * nV * 0.1))
    nsize_2 = int(math.floor(nR * nV * 0.2))
    nsize_3 = int(math.floor(nR * nV * 0.25))
    nsize_4 = int(math.floor(nR * nV * 0.35))

    for n_size in [nsize_1, nsize_2, nsize_3, nsize_4]:
        lines.append(f"echo Running prNum={prNum} - N_SIZE={n_size}\n")
        for i in range(1, runs+1):
            outputfileName = f"""test-runs/bks/$1-{prNum}.{i}"""
            lines.append(f"./runv2.sh {outputfileName} {filename} {n_size} {bks} 0 {threads}\n")
            lines.append("\n")
            # lines.append(f"echo '{prNum}.{i}'\n")
    return lines

def main(outputfile, threads, sample_size, dataset_start, dataset_end):
    # iterate over the files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith('.res'):
            # extract the float value from the first line of the file
            with open(directory_path + filename, 'r') as f:
                float_value = float(f.readline().strip())
            # add the filename and float value to the results dictionary
            bks_dict[filename[:-4]] = float_value
        elif not filename.endswith('.html'):
            with open(directory_path + filename, 'r') as f:
               parts = f.readline().strip().split(" ")

            nR_dict[filename] = int(parts[1])
            nV_dict[filename] = int(parts[0])

    # print the results
    lines = ["#!/bin/bash\n"]
    for i in range(dataset_start, dataset_end+1):
        filename = f'pr' + str(i).zfill(2)
        bks = bks_dict[filename]
        nR = nR_dict[filename]
        nV = nV_dict[filename]
        i_lines = generate_pr_block(i, nR, nV, bks, sample_size, threads)
        lines.extend(i_lines)
        lines.append("\n")

    with open(outputfile, 'w') as file:
        for line in lines:
            file.write(line)
    print('done')

outputfile = input("Output filename: ")
outputfile = outputfile + '.sh'
threads = input("Thread Config (ex: 1 2 4 6 8): ")
sample_size_str = input("Sample Size: ")
sample_size = int(sample_size_str)
datasize_start_str = input("# DataSets start: ")
datasets_start = int(datasize_start_str)
datasize_end_str = input("# DataSets end: ")
dataset_end = int(datasize_end_str)
main(outputfile, threads, sample_size, datasets_start, dataset_end)

def printDatasetDetails():
    print("#############################")
    for d in range(datasets_start, dataset_end+1):
        filename = f"pr{str(d).zfill(2)}"
        print(f"Dataset     =   {filename}    | nR = {nR_dict[filename]}    | nV = {nV_dict[filename]}")
    print("#############################")

printDatasetDetails()


