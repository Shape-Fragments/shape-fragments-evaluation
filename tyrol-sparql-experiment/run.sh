#!/bin/bash
DIR=~
CURRENT_DIR=$(pwd)
cd $DIR
source $DIR/pySHACL-fragments/.venv/bin/activate
export PYTHONPATH=$DIR/pySHACL-fragments
export PATH=$PATH:$DIR/apache-jena-4.2.0/bin
for size in {1..5}
do
  echo "######### Size $size"
  for shape in aggregateratingshape geoshapeshape imageobjectshape sportsactivityshape travelactionshape
  do
    echo "####### Shape $shape"
    echo "### SPARQL"
    # timing
    sparql --time --data tyrol$size.nt --query $CURRENT_DIR/$shape.rq --repeat=2,5 

    # getting fragment
    sparql --data tyrol$size.nt --query $CURRENT_DIR/$shape.rq --results=nt > ${shape}sparqlfragment$size.nt
    
    totaltime=0.0
    for run in {1..5}
    do
      echo "### pySHACL-fragments"
      # timing
      time=$(python pySHACL-fragments/pyshacl/cli.py tyrol$size.nt -o /dev/null -rs=True -s=$CURRENT_DIR/$shape.cut.ttl -df=nt -sf=turtle 2> /dev/null | head 1)

      # getting fragment
      python pySHACL-fragments/pyshacl/cli.py tyrol$size.nt -o ${shape}pyshaclfragment$size.nt -rs=True -s=$CURRENT_DIR/$shape.cut.ttl -df=nt -sf=turtle 2> /dev/null > /dev/null

      totaltime=$(echo "$totaltime+$time" | bc)
      echo "Time: $time sec"
    done

    average= $(echo "$totaltime/$run" | bc)
    echo "Total time: $totaltime sec for repeat count of $run : average: $average"
    echo "Comparing models: "
    rdfcompare ${shape}sparqlfragment$size.nt o ${shape}pyshaclfragment$size.nt
  done
done
