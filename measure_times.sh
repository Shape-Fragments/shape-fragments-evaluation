#!/bin/bash

# create temporary folder where we will store our files:
directory=/data
python=python
mkdir $directory
echo "size;shape;run;validation_time;extraction_time" > $directory/results.csv

# download the data file for the benchmark if it does not exist yet
if [ ! -f $directory/tyrol30m.nt ] ; then
  curl -o $directory/tyrol30m.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=tyrol30m.nq"
  
  # remove xsd:string datatypes as rdflib does not handle these correctly
  sed -i -e 's!\^\^<http://www\.w3\.org/2001/XMLSchema#string>!!g' $directory/tyrol30m.nt

  # remove graph from quads, making it a correct ntriples file 
  sed -i -e 's/ <[^ ]*graph[^ ]*> \.$/ ./g' $directory/tyrol30m.nt
fi

for size in {1..30}; do
  benchmark="tyrol$size"
  mkdir $directory/$benchmark

  # take a sample from the larger benchmark file if it does not yet exist
  if [ ! -f $directory/$benchmark.nt ] ; then
    head -n "$size"000000 $directory/tyrol30m.nt > $directory/$benchmark.nt
  fi
  
  for run in {1..10}; do
    for shape in tyrol/*.ttl; do
      echo "###################"
      echo "BENCHMARK/SHAPE/RUN -> $benchmark / $shape / $run"

      # prioritize pySHACL-timers over any other pyshacl import (e.g. from pip)
      # expects pySHACL-timers repository in sibling directory to this repository
      export PYTHONPATH=../pySHACL-timers

      # expects pySHACL-timers repository in sibling directory to this repository
      validation_time=$($python ../pySHACL-timers/pyshacl/cli.py $directory/$benchmark.nt -o=$directory/$benchmark/${shape:6} -s=$shape -df=nt -sf=turtle | head -n 1)

      # sleep a bit to let the process close down completely
      sleep 10
    
      # prioritize pyshacl-fragments over any other pyshacl import (e.g. from pip)
      # expects pyshacl-fragments repository in sibling directory to this repository
      export PYTHONPATH=../pyshacl-views

      # expects pyshacl-fragments repository in sibling directory to this repository
      extraction_time=$($python ../pyshacl-views/pyshacl/cli.py $directory/$benchmark.nt -o=$directory/$benchmark/${shape:6} -rs=True -s=$shape -df=nt -sf=turtle | head -n 1)

      # sleep a bit to let the process close down completely
      sleep 10

      # append results to csv:
      echo "$size;$shape;$run;$validation_time;$extraction_time" >> $directory/results.csv
    done
  done
done
