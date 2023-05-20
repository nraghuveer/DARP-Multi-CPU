import pandas as pd
import matplotlib.patches as mpatches
import math
import numpy as np
import matplotlib.pyplot as plt

BASEPATH = "./test-runs/bks"
PLOTSPATH = "./plots"
bar_size=0.5

nR_dict = {7: 72, 8: 144, 16: 288, 3: 144, 5: 240, 12: 96, 15: 240, 4: 192, 13: 144, 10: 288, 18: 144, 20: 288, 1: 48, 9: 216, 17: 72, 14: 192, 11: 48, 19: 216, 6: 288, 2: 96}
nV_dict = {7: 4, 8: 6, 16: 13, 3: 7, 5: 11, 12: 5, 15: 11, 4: 9, 13: 7, 10: 10, 18: 6, 20: 10, 1: 3, 9: 8, 17: 4, 14: 9, 11: 3, 19: 8, 6: 13, 2: 5}

def getValue(runID, datasetID, thread, samplesize, nsize):
    csv_file_paths = []
    for i in range(1, samplesize+1):
        path = f"{BASEPATH}/{runID}-{datasetID}.{i}.csv"
        csv_file_paths.append(path)

    # Load the CSV files into a list of pandas DataFrames
    dfs = []
    for csv_file_path in csv_file_paths:
        df = pd.read_csv(csv_file_path, names=['nThreads', 'file', 'total_iterations', 'n_size', 'time_initSolution', 'time_localSearch', 'time_total', 'bestValue', 'version'])
        dfs.append(df)

    # merge all dfs to form single df
    df = pd.concat(dfs)
    df = df.sort_values(by="n_size")

    # for combination of nThreads and n_size -> take average value of time_localsearch
    value = df.loc[(df['nThreads']==thread) & (df['n_size']==nsize)]['time_localSearch'].aggregate('mean')
    return value


def main(runID, plotfilename, dataset_start, dataset_end, samplesize, threads, nsize_percentage):

    plot_file_path = f"{PLOTSPATH}/{plotfilename}.png"

    # Sample data
    datasets = [i for i in range(dataset_start, dataset_end+1)]
    bar_width = 0.35

    # for each dataset, what is base value i.e thread=1
    base_values = {}
    for dataset in datasets:
        nR = nR_dict[dataset]
        nV = nV_dict[dataset]
        nsize = int(math.floor(nR * nV * nsize_percentage))
        val = getValue(runID, dataset, 1, samplesize, nsize)
        base_values[dataset] = val

    dheights = {d: -1 for d in datasets}
    values_group = []
    for thread in threads:
        values = []
        for dataset in datasets:
            nR = nR_dict[dataset]
            nV = nV_dict[dataset]
            nsize = int(math.floor(nR * nV * nsize_percentage))
            val = getValue(runID, dataset, thread, samplesize, nsize)
            base_val = base_values[dataset]
            values.append(base_val / val)
            dheights[dataset] = max(dheights[dataset], values[-1])
        values_group.append(values)

    # Calculate the x-axis positions for each group
    x_groups = [np.arange(len(datasets))]
    for thread in threads[1:]:
        x_group = x_groups[-1] + bar_width
        x_groups.append(x_group)

    # Create a figure and axis
    fig, ax = plt.subplots()

    # Plot the bars for Group 1
    for i, thread in enumerate(threads):
        ax.bar(x_groups[i], values_group[i], bar_width, label=thread)

    # Set the x-axis tick labels
    ax.set_xticks(x_groups[0] + bar_width / 2)
    ax.set_xticklabels(["pr" + str(d).zfill(2) for d in datasets])

    # Set labels and title
    ax.set_xlabel('Dataset')
    ax.set_ylabel('Speedup')

    for i in range(len(datasets)):
        d = i + dataset_start
        nR = nR_dict[d]
        nV = nV_dict[d]
        s = f"{nR * nV}"
        plt.text(i, dheights[d], s)

    ax.legend()

    ax.set_title(f'Speedup compared to 1 thread, N_SIZE = {nsize_percentage * 100}% of nR * nV')
    # Show the plot
    plt.savefig(plot_file_path)

if __name__ == "__main__":
    runID = input("Enter runID: ")
    threads = input("Threads: ")
    threads = threads.split(" ")
    threads = list(map(int, threads))
    print(f"using threads = {threads}")

    for nsize_percentage in [10, 20, 25, 35]:
        for config in [(1, 10, "part1"), (11, 20, "part2")]:
            dataset_start = config[0]
            dataset_end = config[1]
            samplesize = 5
            plotfilename = f"{runID}speedup-{nsize_percentage}-{config[2]}"
            main(runID, plotfilename, dataset_start, dataset_end, samplesize, threads, nsize_percentage/100)
