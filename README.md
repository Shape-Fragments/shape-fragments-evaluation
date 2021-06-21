# README

## Requirements
- pySHACL-timers code installed in sibling directory
- pyshacl-fragments code installed in sibling directory
- docker
- python 3.6

## Correctness experiment (SHACL vs SPARQL)
1. Download datasets and load them into dockerized triplestores by running: `./start_containers.sh`
2. Wait a bit for step 1 to complete
3. Execute SPARQL queries and save results by running: `./execute_queries.sh`
4. Execute shape fragment extraction, while comparing results with SPARQL results, by running: `./extract_fragments.sh`

## Overhead experiment (pyshacl-fragments vs pySHACL)
1. Download datasets and shapes, and measure the two engines performance on them by running: `./measure_times.sh`
2. Wait quite a bit for step 1 to finish
3. Perhaps force-quit step 1 after the first dataset size is done, unless your machine is awesome
4. Visualize the results: `python3.6 visualize.py`
