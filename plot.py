import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('tpch1_test.csv')

sns.set(style="whitegrid")

plt.figure(figsize=(5, 6))
sns.boxplot(x='Type', y='Real Time (s)', data=df)

plt.title('Execution Time of TPCH query 1', fontsize=16)
plt.xlabel('Network Type', fontsize=12)
plt.ylabel('Real Time (s)', fontsize=12)

plt.savefig('real_time_box_plot_highres.png', format='png', dpi=300)

plt.close()

print("Box plot saved as 'real_time_box_plot.png'")
