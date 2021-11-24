#!/bin/bash
DIR=${1:-~}
EXPERIMENT_DIR=$(pwd)

cd $DIR

export PATH=$PATH:$DIR/apache-jena-4.2.0/bin
export PATH=$PATH:$DIR/apache-jena-fuseki-4.2.0

for year in {2021..2010}
do
  wget curl -o authoredBySince$year.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=authoredBySince$year.nt"

  cd graphdb-docker/preload
  rm import/*
  cp $DIR/authoredBySince$year.nt import/
  docker-compose build
  docker-compose up -d
  docker logs -f graphdb-preload | sed '/PreloadData - finish/ q' > /dev/null
  cd ..
  docker-compose up -d
  docker logs -f graphdb | sed '/Started GraphDB in workbench mode/ q' > /dev/null
  
  # fire a test query so graphdb can load its plugins
  curl -d "SELECT * WHERE { ?s ?p ?o } LIMIT 10" -H 'Content-Type: application/sparql-query' http://localhost:7200/repositories/demo > /dev/null
  
  time curl -d @$EXPERIMENT_DIR/moshevardifragment3.rq -H 'Content-Type: application/sparql-query' http://localhost:7200/repositories/demo -o /dev/null

  docker logs graphdb > graphdb$year.log

  docker-compose down
  rm preload/import/*
  cd ..

  tdbloader2 --loc authoredBySince$year authoredBySince$year.nt

  fuseki-server --loc authoredBySince$year /sparql &> fuseki$year.log
  tail -n 20 -f fuseki$year.log sed '/Started Server/ q' > /dev/null

  curl -d "SELECT * WHERE { ?s ?p ?o } LIMIT 10" -H 'Content-Type: application/sparql-query' http://localhost:3030/sparql > /dev/null
  
  time curl -d @$EXPERIMENT_DIR/moshevardifragment3.rq -H 'Content-Type: application/sparql-query' http://localhost:3030/sparql -o /dev/null

  rm -r authoredBySince$year

  rm authoredBySince$year.nt
done
