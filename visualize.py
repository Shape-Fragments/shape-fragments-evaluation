import csv
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
from matplotlib.font_manager import FontProperties
import numpy as np
import statistics

benchmarks = {}

with open('results.csv', 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';')

    # parse results in csv file and group them per size and shape
    firstrow = True
    for row in reader:
        # skip header row (there might be better ways to do this)
        if firstrow:
            firstrow = False
            continue

        shape = row[1]
        # skip empty measurements
        if row[3] is not '' and row[4] is not '':
            benchmark = row[0]
            eval_time = float(row[3])
            extract_time = float(row[4])
            if benchmark not in benchmarks:
                benchmarks[benchmark] = {'eval_times': {}, 'extract_times': {}, 'eval_average': {},
                                         'extract_average': {}, 'eval_stdev': {}, 'extract_stdev': {},
                                         'overhead_average': {}}
            if shape not in benchmarks[benchmark]['eval_times']:
                benchmarks[benchmark]['eval_times'][shape] = [eval_time]
                benchmarks[benchmark]['extract_times'][shape] = [extract_time]
            else:
                benchmarks[benchmark]['eval_times'][shape].append(eval_time)
                benchmarks[benchmark]['extract_times'][shape].append(extract_time)

# calculate avarage time between runs per shape for extraction/evaluation and also calculate overhead:
for benchmark in benchmarks:
    for shape in benchmarks[benchmark]['eval_times']:
        benchmarks[benchmark]['eval_average'][shape] = sum(benchmarks[benchmark]['eval_times'][shape]) / len(
            benchmarks[benchmark]['eval_times'][shape])
        benchmarks[benchmark]['eval_stdev'][shape] = statistics.stdev(benchmarks[benchmark]['eval_times'][shape])
        benchmarks[benchmark]['extract_stdev'][shape] = statistics.stdev(benchmarks[benchmark]['extract_times'][shape])
        benchmarks[benchmark]['extract_average'][shape] = sum(benchmarks[benchmark]['extract_times'][shape]) / len(
            benchmarks[benchmark]['extract_times'][shape])
        benchmarks[benchmark]['overhead_average'][shape] = benchmarks[benchmark]['extract_average'][shape] / \
                                                           benchmarks[benchmark]['eval_average'][shape]

for benchmark in benchmarks:
    print(benchmark)
    print(sorted(benchmarks[benchmark]['eval_average'].values()))
    print(sorted(benchmarks[benchmark]['eval_average'].items()))
    print(sorted(benchmarks[benchmark]['overhead_average'].values()))

# shapes with large difference between lowest eval time and lowest eval time are interesting for evaluation
interesting_shapes = []
for shape in benchmarks['1']['eval_average']:
    if benchmarks['4']['eval_average'][shape] / benchmarks['1']['eval_average'][shape] > 1.1:
        interesting_shapes.append(shape)

# latex font
font = FontProperties(fname='OldStandardTT-Regular.ttf')

fig, axes = plt.subplots(4, 2, sharex=True)
for i in range(8):
    shape = interesting_shapes[i]
    sizes = sorted([int(key) for key in benchmarks.keys()])
    eval_average = [benchmarks[str(size)]['eval_average'][shape] for size in sizes]
    extract_average = [benchmarks[str(size)]['extract_average'][shape] for size in sizes]
    print(eval_average)
    print(extract_average)
    ax = axes[i // 2][i % 2]
    ax.plot(sizes, eval_average, linewidth=0.75, color='black')
    ax.plot(sizes, extract_average, linewidth=0.75, color='black', linestyle='dashed')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)

    ax.text(1, 0.2, shape[6:-9], ha='right', va='bottom', transform=ax.transAxes, fontproperties=font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(font)
    for label in ax.get_xticklabels():
        label.set_fontproperties(font)

plt.text(0.025, 0.5, "Execution time (seconds)", ha='center', va='center', transform=fig.transFigure, rotation=90,
         fontproperties=font)
plt.text(0.5, 0.025, "Data graph size (million triples)", ha='center', va='center', transform=fig.transFigure,
         fontproperties=font)
plt.show()
fig.savefig("interesting_times.pdf")