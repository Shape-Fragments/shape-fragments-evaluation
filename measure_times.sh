#!/bin/bash

# create temporary folder where we will store our files:
directory=/tmp/shape-views-validation 
mkdir $directory
mkdir $directory/tyrol

for benchmark in "tyrol" "tyrol23m" "tyrol30m"; do
  # download the data file for the benchmark if it does not exist yet
  if [ ! -f $directory/$benchmark.nt ] ; then
    curl -o $directory/$benchmark.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=$benchmark.nq"
    
    # remove xsd:string datatypes as rdflib does not handle these correctly
    sed -i -e 's!\^\^<http://www\.w3\.org/2001/XMLSchema#string>!!g' $directory/$benchmark.nt

    # remove graph from quads, making it a correct ntriples file 
    sed -i -e 's/ <[^ ]*graph[^ ]*> \.$/ ./g' $directory/$benchmark.nt
  fi

  echo "benchmark;shape;run;validation_time;extraction_time" > results.csv
  
  for run in {1..15}; do
    for shape in $benchmark/*.ttl; do
      echo "###################"
      echo "SHAPE / RUN :   $shape / $run"

      # prioritize pySHACL-timers over any other pyshacl import (e.g. from pip)
      # expects pySHACL-timers repository in sibling directory to this repository
      export PYTHONPATH=../pySHACL-timers

      # expects pySHACL-timers repository in sibling directory to this repository
      validation_time=$(/usr/bin/python3.6 ../pySHACL-timers/pyshacl/cli.py /tmp/shape-views-validation/$benchmark.nt -o=/tmp/shape-views-validation/$shape -s=$shape -df=nt -sf=turtle | head -n 1)

      # sleep a bit to let the process close down completely
      sleep 10
    
      # prioritize pyshacl-views over any other pyshacl import (e.g. from pip)
      # expects pyshacl-views repository in sibling directory to this repository
      export PYTHONPATH=../pyshacl-views

      # expects pyshacl-views repository in sibling directory to this repository
      extraction_time=$(/usr/bin/python3.6 ../pyshacl-views/pyshacl/cli.py /tmp/shape-views-validation/$benchmark.nt -o=/tmp/shape-views-validation/$shape -rs=True -s=$shape -df=nt -sf=turtle | head -n 1)

      # sleep a bit to let the process close down completely
      sleep 10

      # append results to csv:
      echo "$benchmark;$shape;$run;$validation_time;$extraction_time" >> results.csv
    done
  done
done
