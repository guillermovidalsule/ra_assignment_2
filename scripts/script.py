import pandas as pd

# Load CSV (100 rows + header)
df = pd.read_csv("results/D_Choice_20_Low.csv")

# Extract C and D columns
data = df[['C', 'G']]

# Number of rows per sub-table
chunk_size = 25

latex = "\\begin{table}[h]\n\\centering\n"

# Generate 4 subtables of 25 rows each
for i in range(4):
    chunk = data.iloc[i*chunk_size:(i+1)*chunk_size]
    latex += "\\begin{tabular}{c|c}\n"
    for _, row in chunk.iterrows():
        latex += f"    {row['C']} & {row['G']} \\\\\n"
    latex += "\\end{tabular}\n\\hspace{0.5cm}\n"

latex += "\\caption{Caption}\n"
latex += "\\label{tab:placeholder}\n"
latex += "\\end{table}"

print(latex)
