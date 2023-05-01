import pandas as pd
import matplotlib.pyplot as plt

# Get the CSV file path from the user
csv_file_path = input("Enter the path of the CSV file: ")
time_column = "time_total"
# Load the CSV file into a pandas DataFrame
df = pd.read_csv(csv_file_path)

# Get the base time_localSearch value where nThreads = 1
base_time = df[df['nThreads'] == 1][time_column].values[0]

# Calculate the speedup for each row
df['speedup'] = base_time / df[time_column]

# Generate the plot
plt.plot(df['nThreads'], df['speedup'], marker='o')
plt.xlabel('nThreads')
plt.ylabel('Speedup')
plt.title('Speedup vs. nThreads')
plt.show()