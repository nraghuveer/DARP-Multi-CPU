import sys
import numpy as np
import itertools
import pandas as pd
import matplotlib.pyplot as plt

threads = [1,2,4,8]
requests = [50, 350, 500, 650, 100]
area_of_service = [10]
service_duration = [2, 4, 8, 12, 16, 24]


def main():
    filename = sys.argv[1]
    sd = int(sys.argv[2])
    aos = 10
    # fig, axs = plt.subplots(len(service_duration))
    # fig.suptitle(f'Heading here')
    # for i, sd in enumerate(service_duration):
    #     print(sd)
    #     add_plot(axs[i], filename, threads, aos, sd)

    # # plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    # plt.show()

    compare_tt_across_threads(filename, threads, aos, sd)

def add_plot(ax, filename, threads, aos, sd):
    df = pd.read_csv(filename)
    # plt.xlabel("Number of requests")
    # plt.ylabel("Total Time")
    for thread in threads:
        points = [(row['nR'], row['time_total']) for _, row in df.iterrows() if (int(row['sd']) == sd and int(row['aos']) == aos and int(row['nThreads']) == thread)]
        ax.plot([x[0] for x in points], [x[1] for x in points])
    # plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    # plt.show()



def compare_tt_across_threads(filename, threads, aos, sd):
    df = pd.read_csv(filename)
    plt.suptitle("Varying total times with differnt thread configurations")
    plt.xlabel("Number of requests")
    plt.ylabel("Total Time")
    for thread in threads:
        points = [(row['nR'], row['time_total']) for _, row in df.iterrows() if (int(row['sd']) == sd and int(row['aos']) == aos and int(row['nThreads']) == thread)]
        plt.plot([x[0] for x in points], [x[1] for x in points])
    plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    plt.show()


if __name__ == "__main__":
    main()