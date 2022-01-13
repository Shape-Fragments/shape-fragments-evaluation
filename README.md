# README
This repository contains the code to run experiments that are designed to test the Shape Fragments implementations [SHACL2SPARQL](https://github.com/shape-fragments/shacl2sparql) and [pySHACL-fragments](https://github.com/shape-fragments/pyshacl-fragments). For detailed descriptions of the experiments and interpretations of the results we refer to the [paper](https://github.com/shape-fragments/full-paper)

## Requirements
- pySHACL-timers code installed in sibling directory
- pySHACL-fragments code installed in sibling directory
- docker
- python 3.6 or higher

## Usage

### Correctness experiment (SHACL vs SPARQL)
1. Download datasets and load them into dockerized triplestores by running: `./start_containers.sh`
2. Wait a bit for step 1 to complete
3. Execute SPARQL queries and save results by running: `./execute_queries.sh`
4. Execute shape fragment extraction, while comparing results with SPARQL results, by running: `./extract_fragments.sh`

### Overhead experiment (pyshacl-fragments vs pySHACL)

To run on a local machine:

1. Set an environment variable `size` to a value between `1` and `30`, this will determine which benchmark size will be run: `export size=1`.
2. Download datasets and shapes, and measure the two engines' performance on them by running: `./measure_times.sh`.

To run with docker:

1. Build the docker image: `docker build . -t overhead`
2. Run the container: `docker run -v <path>:/data/ -e size=<size> overhead:latest`. `<path>` should be replaced by an absolute path to a directory where data can be persisted. `<size>` should be set to the benchmark size (`1`-`30`).

### Tyrol-SPARQL and Vardi experiments
For instructions for installation of and running the Tyrol-SPARQL and Vardi experiments, refer to the READMEs in the directories `tyrol-sparql-experiment` and `vardi-fragment-experiment`.
