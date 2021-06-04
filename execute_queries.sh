#!/bin/bash

# create temporary folder where we will store our files:
directory=/tmp/shape-views-validation 
mkdir $directory

for benchmark in "watdiv" "bsbm"; do
  if [ "$benchmark" == "watdiv" ]; then
    port=3030
  else
    port=3031
  fi

  container_address=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $benchmark)

  # make directory for storing query results:
  mkdir $directory/$benchmark

  # iterate over the shapes of this benchmark
  for shape in shapes/$benchmark/*.ttl; do
    # identifier of query/shape
    code=${shape:8+${#benchmark}:${#shape}-12-${#benchmark}}
    # relative path of query corresponding to shape:
    query=queries/$benchmark/$code.rq
    echo "###################"
    echo "Sending query $code"
    curl --data "@$query" -vvv -o $directory/$benchmark/$code.nt -H "Content-Type: application/sparql-query" "http://$container_address:$port/sparql"
  done
done
