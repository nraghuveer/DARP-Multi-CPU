import pandas as pd
import matplotlib.pyplot as plt

BASEPATH = "./test-runs/bks"
PLOTSPATH = "./plots"

TOTAL_DATASETS = 20
SAMPLE_SIZE = 5

# Prfix path
def addToPlot(runID, datasetID):
    csv_file_paths = []
    for i in range(1, 2):
        csv_file_paths.append(f"{BASEPATH}/{runID}-{datasetID}.{i}.csv")

    # Load the CSV files into a list of pandas DataFrames
    dfs = []
    for csv_file_path in csv_file_paths:
        df = pd.read_csv(csv_file_path, names=['nThreads', 'file', 'total_iterations', 'n_size', 'time_initSolution', 'time_localSearch', 'time_total', 'bestValue', 'version'])
        dfs.append(df)

    # Calculate the average time_localSearch for each row across all DataFrames
    average_times = []
    for row_index in range(len(dfs[0])):
        row_times = []
        for df in dfs:
            row_times.append(df.iloc[row_index]['time_localSearch'])
        row_average = sum(row_times) / len(row_times)
        average_times.append(row_average)

    # Get the base time_localSearch value where nThreads = 1
    base_time = average_times[0]

    # Calculate the speedup for each row using the average time_localSearch values
    speedups = []
    for time in average_times:
        speedup = base_time / time
        speedups.append(speedup)

    # Generate the plot
    nThreads = dfs[0]['nThreads'].tolist()
    plt.plot(nThreads, speedups, marker='o', label=f"pr0{datasetID}")
    plt.xlabel('nThreads')
    plt.ylabel('Speedup')
    nsize = dfs[0].iloc[0].n_size
    plt.title(f'nsize={nsize} | Speedup vs. nThreads')

def main():
    runID = input("Enter runID: ")
    filename = input("Output filename: ")
    plot_file_path = f"{PLOTSPATH}/{filename}.png"

    for datasetID in range(1, TOTAL_DATASETS + 1):
        addToPlot(runID, datasetID)
    plt.legend(bbox_to_anchor=(1.05, 1.0), loc="upper left")
    plt.tight_layout()
    plt.savefig(plot_file_path)
    print(f"File saved in {plot_file_path}")

if __name__ == "__main__":
    main()
