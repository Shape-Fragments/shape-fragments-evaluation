import csv
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
import statistics

shapes = {}

with open('results.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')

    # parse results in csv file and group them per size and shape
    firstrow = True
    for row in reader:
        # skip header row (there might be better ways to do this)
        if firstrow:
            firstrow = False
            continue

        shape = row[0]
        size = float(row[1])
        tool = row[2]
        time = float(row[3])

        if shape in shapes:
            if tool in shapes[shape]:
                shapes[shape][tool][size] = time
            else:
                shapes[shape][tool] = {size: time}
        else:
            shapes[shape] = {tool: {size: time}}

# latex font
font = FontProperties(fname='../OldStandardTT-Regular.ttf')

fig, axes = plt.subplots(3, 1, sharex=True, figsize=(4, 4))
for i, shape in enumerate(['offer', 'openinghoursspecification', 'postaladdress']):
    ax = axes[i]
    linestyles = [':', '--', '-.']
    for tool, style in zip(shapes[shape], linestyles):
        sizes = sorted(shapes[shape][tool])
        ax.plot(sizes, [shapes[shape][tool][size] for size in sizes], linewidth=0.75, color='black', linestyle=style)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(True)
    ax.spines['left'].set_visible(True)
    #ax.set_yscale('log')
    ax.text(1, 0.2, shape, ha='right', va='bottom', transform=ax.transAxes, fontproperties=font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(font)
    for label in ax.get_xticklabels():
        label.set_fontproperties(font)

plt.text(0.025, 0.5, "Execution time (seconds)", ha='center', va='center', transform=fig.transFigure, rotation=90,
         fontproperties=font)
plt.text(0.5, 0.025, "Data graph size (million triples)", ha='center', va='center', transform=fig.transFigure,
         fontproperties=font)
plt.show()
fig.savefig("shacl2sparql-times.pdf")
