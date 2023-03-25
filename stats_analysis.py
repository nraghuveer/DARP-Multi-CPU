import sys
import numpy as np
import itertools
import pandas as pd
import matplotlib.pyplot as plt

threads = [1,2,4,8, 16, 24, 30]
requests = [50, 350, 500, 650, 100]


def main():
    filename = sys.argv[1]
    nR = int(sys.argv[2])
    aos = 10
    sd = 2
    # fig, axs = plt.subplots(len(service_duration))
    # fig.suptitle(f'Heading here')
    # for i, sd in enumerate(service_duration):
    #     print(sd)
    #     add_plot(axs[i], filename, threads, aos, sd)

    # # plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    # plt.show()

    # compare_tt_across_threads(filename, threads, aos, sd)
    show_speedup(filename, [1,2,4,8,16,32,56], nR, aos, sd)

def add_plot(ax, filename, threads, aos, sd):
    df = pd.read_csv(filename)
    # plt.xlabel("Number of requests")
    # plt.ylabel("Total Time")
    for thread in threads:
        points = [(row['nR'], row['time_total']) for _, row in df.iterrows() if (int(row['sd']) == sd and int(row['aos']) == aos and int(row['nThreads']) == thread)]
        ax.plot([x[0] for x in points], [x[1] for x in points])
    # plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    # plt.show()



def show_speedup(filename, threads, nR, aos, sd):
    threads.sort()
    def getTime(t, nR, df):
        x = [row['time_total'] for _, row in df.iterrows() if (int(row['nR']) == nR and int(row['nThreads']==t))]
        return x[0] if x else None
    df = pd.read_csv(filename, header=0)
    plt.suptitle("Speedups")
    plt.xlabel("Threads")
    plt.ylabel("Speedup")
    base = getTime(1, nR, df)

    values = []
    speedup = {}
    for thread in threads:
        if thread == 1:
            continue
        # for each thread, get base value and calc speedup
        cur = getTime(thread, nR, df)
        if not cur:
            continue
        print(f"thread={thread} | speedup={cur/base} | cur={cur}| base={base}")
        values.append((thread, base/cur))

    values.sort(key=lambda x: x[0])
    print(values)
    xvalues = [x[0] for x in values]
    yvalues = [x[1] for x in values]
    plt.plot(xvalues, yvalues)
    plt.legend([f"{t} Threads" for t in threads], loc='upper left')
    plt.savefig("plot.png")

def compare_tt_across_threads(filename, threads, aos, sd):
    df = pd.read_csv(filename, header=0)
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
