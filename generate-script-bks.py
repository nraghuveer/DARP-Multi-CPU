import os

directory_path = './benchmark-data/chairedistributique/data/darp/tabu/'
threads = [1,2,4,8,16,32,64]
SAMPLE_SIZE = 3
DATASET_SIZE = 20

# initialize an empty dictionary to store the results
results = {}

def generate_pr_block(prNum, bks, runs):
    filename = f'pr' + str(prNum).zfill(2)
    lines = []
    for i in range(1, runs+1):
        outputfileName = f"""test-runs/$1-{prNum}.{i}"""
        lines.append(f"""filename="test-runs/$1-{prNum}.{i}.csv"\n""")
        lines.append(f"""if [ ! -e "$filename"  ]\n""")
        lines.append("then\n")
        lines.append(f"    ./runv2.sh {outputfileName} {filename} $2 {bks} {' '.join(map(str, threads))} >> logs/$1.txt\n")
        lines.append("fi\n")
        lines.append(f"echo '{prNum}.{i}'\n")
        lines.append("\n")
        # lines.append(f"echo '{prNum}.{i}'\n")
    return lines

def main(outputfile):
    # iterate over the files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith('.res'):
            # extract the float value from the first line of the file
            with open(directory_path + filename, 'r') as f:
                float_value = float(f.readline().strip())
            # add the filename and float value to the results dictionary
            results[filename[:-4]] = float_value

    # print the results
    print(results)
    lines = ["#!/bin/bash\n"]
    for i in range(1, DATASET_SIZE + 1):
        filename = f'pr' + str(i).zfill(2)
        bks = results[filename]
        i_lines = generate_pr_block(i, bks, SAMPLE_SIZE)
        lines.extend(i_lines)
        lines.append("\n")

    with open(outputfile, 'w') as file:
        for line in lines:
            file.write(line)
    print('done')

outputfile = input("Output filename: ")
outputfile = outputfile + '.sh'
main(outputfile)


