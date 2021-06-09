#!/bin/bash

# create temporary folder where we will store our files:
directory=/tmp/shape-views-validation 
mkdir $directory

for benchmark in "watdiv" "bsbm"; do
  # download the data file for the benchmark if it does not exist yet
  if [ ! -f $directory/$benchmark.nt ] ; then
    curl -o $directory/$benchmark.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=$benchmark.nt"

    # remove xsd:string datatypes as rdflib does not handle these correctly
    sed -i -e 's!\^\^<http://www\.w3\.org/2001/XMLSchema#string>!!g' /tmp/$directory/$benchmark.nt
  fi

  if [ "$benchmark" == "watdiv" ]; then
    port=3030
  else
    port=3031
  fi

  # kill and remove existing containers:
  docker kill $benchmark
  docker rm $benchmark

  # start a docker container with a triplestore hosting the bsbm data:
  docker run -p $port:$port --name $benchmark --mount type=bind,source=$directory/$benchmark.nt,target=/data/$benchmark.nt stain/jena-fuseki -- ./fuseki-server --port $port --file=/data/$benchmark.nt /sparql &
done
