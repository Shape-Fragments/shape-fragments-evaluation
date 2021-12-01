import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.font_manager import FontProperties

tools = {}

with open('results.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')

    # parse results in csv file and group them per size and shape
    firstrow = True
    for row in reader:
        # skip header row (there might be better ways to do this)
        if firstrow:
            firstrow = False
            continue

        tool = row[0]
        size = float(row[1])/1000000
        time = float(row[2])/60

        if tool in tools:
            tools[tool][size] = time
        else:
            tools[tool] = {size: time}

font = FontProperties(fname='../OldStandardTT-Regular.ttf')
fig, axes = plt.subplots(1, 1, sharex=True, figsize=(4, 3.5))
ax = axes
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(True)
ax.spines['left'].set_visible(True)
for label in ax.get_yticklabels():
    label.set_fontproperties(font)
for label in ax.get_xticklabels():
    label.set_fontproperties(font)
sizes = sorted(tools[tool])
ax.xaxis.set_minor_locator(ticker.FixedLocator(sizes))

linestyles = ['-.', ':', '--']
for tool, style in zip(tools, linestyles):
    ax.plot(sizes, [tools[tool][size] for size in sizes],
            marker=".", markersize=3,
            linewidth=0.75, color='black', linestyle=style,
            label=tool)

odd = False
for i, size in zip(range(12), sizes):
    odd = not odd
    if odd:
        continue
    year = 2021 - i
    print(f"{size}, {year}")
    ax.text(size+0.13, tools["graphdb"][size]+1.5, f"{year}", horizontalalignment="right", fontproperties=font)


plt.text(0.025, 0.5, "Execution time (minutes)", ha='center', va='center', transform=fig.transFigure, rotation=90,
         fontproperties=font)
plt.text(0.5, 0.02, "Data graph size (million triples)", ha='center', va='center', transform=fig.transFigure,
         fontproperties=font)
plt.show()
fig.savefig("vardi_times.pdf")
