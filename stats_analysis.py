import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def main():
    filename = sys.argv[1]
    show(filename)

def show(filename):
    # for same filename
    # read all thread files
    #1. show the time....
    #   time on y, threads on x
    threads = [1, 2, 4, 8]
    dfs = {t: pd.read_csv(f"{filename}_{t}.csv") for t in threads}
    plt.plot(threads, [dfs[t].time_total for t in threads])
    plt.ylabel("Total Time")
    plt.xlabel("Threads")
    plt.show()



if __name__ == "__main__":
    main()