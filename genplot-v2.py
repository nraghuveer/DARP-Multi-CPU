import pandas as pd
import matplotlib.pyplot as plt

BASEPATH = "./test-runs"
PLOTSPATH = "./plots"

# Prfix path
def addToPlot(runID, datasetID):
    csv_file_paths = []
    for i in range(1, 6):
        csv_file_paths.append(f"{BASEPATH}/{runID}-{datasetID}.{i}.csv")

    # Load the CSV files into a list of pandas DataFrames
    dfs = []
    for csv_file_path in csv_file_paths:
        df = pd.read_csv(csv_file_path, names=['nThreads', 'file', 'total_iterations', 'n_size', 'time_initSolution', 'time_localSearch', 'time_total', 'version'])
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

def main():
    runID = input("Enter runID: ")
    runID = int(runID)
    plot_file_path = f"{PLOTSPATH}/{runID}.png"
    for datasetID in range(1, 7):
        addToPlot(runID, datasetID)
    plt.legend(loc="upper left")
    plt.title(f'Speedup vs. nThreads')
    plt.savefig(plot_file_path)
    print(plot_file_path)

if __name__ == "__main__":
    main()