import csv
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import numpy as np
import statistics

eval_times = {}
extract_times = {}

with open('results.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')

    # parse results in csv file and group them per shape
    firstrow = True
    for row in reader:
        # skip header row (there might be better ways to do this)
        if firstrow:
            firstrow = False
            continue

        shape = row[1]
        # skip empty measurements
        if row[3] is not '' and row[4] is not '':
            eval_time = float(row[3])
            extract_time = float(row[4])
            if shape not in eval_times:
                eval_times[shape] = [eval_time]
                extract_times[shape] = [extract_time]
            else:
                eval_times[shape].append(eval_time)
                extract_times[shape].append(extract_time)

# calculate avarage time between runs per shape for extraction/evaluation and also calculate overhead:
eval_avarage = {}
extract_avarage = {}
overhead_average = {}
for shape in eval_times:
    eval_avarage[shape] = sum(eval_times[shape]) / len(eval_times[shape])
    extract_avarage[shape] = sum(extract_times[shape]) / len(extract_times[shape])
    overhead_average[shape] = extract_avarage[shape] / eval_avarage[shape]
print(
    f"Average evaluation time is {statistics.mean(eval_avarage.values())} seconds (stdev {statistics.stdev(eval_avarage.values())})")
print(
    f"Average extraction time is {statistics.mean(extract_avarage.values())} seconds (stdev {statistics.stdev(extract_avarage.values())})")

# get order index arrays for evaluation:
increasing_eval_time = sorted(eval_avarage.keys(), key=eval_avarage.__getitem__)
increasing_extract_time = sorted(extract_avarage.keys(), key=extract_avarage.__getitem__)
increasing_overhead = sorted(overhead_average.keys(), key=overhead_average.__getitem__)
print([eval_avarage[shape] for shape in increasing_eval_time])
# create plot
fig, ax = plt.subplots()
fig.set_size_inches(12.2/2.54, 8/2.54)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['left'].set_visible(False)
index = np.arange(len(increasing_eval_time))
bar_width = 0.35
opacity = 0.8
ax.yaxis.set_major_formatter(FormatStrFormatter('%.0f'))

rects1 = plt.bar(index, [eval_avarage[shape] * 1000 for shape in increasing_eval_time], bar_width,
                 alpha=opacity,
                 color='black',
                 label='Evaluation')

rects2 = plt.bar(index + bar_width, [extract_avarage[shape] * 1000 for shape in increasing_eval_time], bar_width,
                 alpha=opacity,
                 color='grey',
                 label='Extraction')

plt.xlabel('Shapes')
plt.text(0.12, 0.96, "Time (ms)", horizontalalignment='center', verticalalignment='center', transform=ax.transAxes)
plt.yscale('log')
plt.tick_params(
    axis='x',  # changes apply to the x-axis
    which='both',  # both major and minor ticks are affected
    bottom=False,  # ticks along the bottom edge are off
    top=False,  # ticks along the top edge are off
    labelbottom=False)  # labels along the bottom edge are offplt.legend()
plt.tick_params(
    axis='y',  # changes apply to the x-axis
    which='minor',  # minor ticks are affected
    left=False,  # ticks along the left edge are off
    right=False)  # ticks along the right edge are off
plt.legend(loc='upper center', frameon=False)
plt.tight_layout()
plt.show()
fig.savefig("times.pdf")

fig, ax = plt.subplots()
fig.set_size_inches(12.2/2.54, 6/2.54)
plt.bar(range(len(increasing_overhead)),
        [(overhead_average[shape] - 1.0) * 100 for shape in increasing_overhead],
        color='grey')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['left'].set_visible(False)
plt.xticks([])
plt.yticks([-10, 0, 10])
plt.text(0.25, 0.975, "Overhead (percentage)", horizontalalignment='center', verticalalignment='center',
         transform=ax.transAxes)
plt.text(0.5, 0.5, "Shapes", horizontalalignment='center', verticalalignment='center', transform=ax.transAxes)
plt.tight_layout()
plt.show()
fig.savefig("overhead.pdf")
