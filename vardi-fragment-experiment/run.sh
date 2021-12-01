#!/bin/bash
DIR=${1:-~}
EXPERIMENT_DIR=$(pwd)

cd $DIR

export PATH=$PATH:$DIR/apache-jena-4.2.0/bin
export PATH=$PATH:$DIR/apache-jena-fuseki-4.2.0

for year in {2021..2010}
do
  echo "######### Year $year"
  curl -o authoredBySince$year.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=authoredBySince$year.nt"
  
  echo "###### GraphDB"
  cd graphdb-docker/preload
  cp $DIR/authoredBySince$year.nt import/authoredBy.nt
  docker-compose build 
  docker-compose up -d
  docker logs -f graphdb-preload > /dev/null
  cd ..
  docker-compose up -d
  ( docker logs -f graphdb & ) | grep -q "Started GraphDB"
  
  # fire a test query so graphdb can load its plugins
  curl -d "SELECT * WHERE { ?s ?p ?o } LIMIT 10" -H 'Content-Type: application/sparql-query' http://localhost:7200/repositories/demo > /dev/null
  
  #echo "loading done, executing queries"
  for i in {1..5}
  do
    echo "### run $i"
    time curl -d @$EXPERIMENT_DIR/moshevardifragment3.rq -H 'Content-Type: application/sparql-query' http://localhost:7200/repositories/demo -o /dev/null
  done

  docker logs graphdb > graphdb$year.log

  docker-compose down
  cd preload
  docker-compose down
  cd ..
  rm preload/import/*
  cd ..
  echo "cleanup done"

  echo "###### Jena Fuseki TDB2"
  tdbloader2 --loc authoredBySince$year authoredBySince$year.nt

  #fuseki-server --loc authoredBySince$year /sparql &> fuseki$year.log &
  fuseki-server --loc authoredBySince$year /sparql &> fuseki$year.log &
  PID=$!
  ( tail -n 10 -f fuseki$year.log & ) | grep -q "Started Server"

  echo "loading done, executing queries"
  for i in {1..5}
  do
    echo "### run $i"
    time curl -d @$EXPERIMENT_DIR/moshevardifragment3.rq -H 'Content-Type: application/sparql-query' http://localhost:3030/sparql -o /dev/null
  done
  

  kill $PID

  rm -r authoredBySince$year

  rm authoredBySince$year.nt
  echo "cleanup done"
done
