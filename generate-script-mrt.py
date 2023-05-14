import os

directory_path = './benchmark-data/chairedistributique/data/darp/tabu/'
threads = [1,2,4,8,16]
SAMPLE_SIZE = 1
DATASET_SIZE = 20

def generate_pr_block(prNum, mrt, runs):
    filename = f'pr' + str(prNum).zfill(2)
    lines = []
    for i in range(1, runs+1):
        outputfileName = f"""test-runs/mrt/$1-{prNum}.{i}"""
        lines.append(f"""filename="test-runs/mrt/$1-{prNum}.{i}.csv"\n""")
        lines.append(f"""if [ ! -e "$filename"  ]\n""")
        lines.append("then\n")
        lines.append(f"    ./runv2.sh {outputfileName} {filename} $2 0 {mrt} {' '.join(map(str, threads))} >> logs/$1.txt\n")
        lines.append("fi\n")
        lines.append(f"echo '{prNum}.{i}'\n")
        lines.append("\n")
        # lines.append(f"echo '{prNum}.{i}'\n")
    return lines

def main(outputfile, mrt):
    # print the results
    lines = ["#!/bin/bash\n"]
    for i in range(1, DATASET_SIZE + 1):
        filename = f'pr' + str(i).zfill(2)
        i_lines = generate_pr_block(i, mrt, SAMPLE_SIZE)
        lines.extend(i_lines)
        lines.append("\n")

    with open(outputfile, 'w') as file:
        for line in lines:
            file.write(line)
    print('done')

outputfile = input("Output filename: ")
mrt = input("Max Runtime in seconds: ")
outputfile = outputfile + '.sh'
mrt = int(mrt)
main(outputfile, mrt)


