import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

queries = range(1, 23)
for query in queries:
    df = pd.read_csv(f"tpch{query:02d}.csv")

    sns.set_theme(style="whitegrid")

    plt.figure(figsize=(5, 6))
    sns.boxplot(x='Command Name', y='Real Time (s)', data=df)

    plt.title(f"Execution Time of TPCH query {query:02d}", fontsize=14)
    plt.xlabel('Network Type', fontsize=12)
    plt.ylabel('Real Time (s)', fontsize=12)
    plt.ylim(0, df['Real Time (s)'].max() * 1.05)
    plt.tight_layout()
    plt.savefig(f"tpch{query:02d}.png", format='png', dpi=300)

    plt.close()

    print(f"Box plot saved as tpch{query:02d}.png")
