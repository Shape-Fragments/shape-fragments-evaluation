#!/bin/bash
DIR=~
CURRENT_DIR=$(pwd)
cd $DIR
source $DIR/pySHACL-fragments/.venv/bin/activate
export PYTHONPATH=$DIR/pySHACL-fragments
export PATH=$PATH:$DIR/apache-jena-4.2.0/bin
for size in 1 1.5 2 2.5 3 3.5 4 4.5 5
do
  echo "######### Size $size"
  for shape in aggregateratingshape offershape openinghoursspecificationshape postaladdressshape travelactionshape
  do
    echo "###### Shape $shape"
    echo "### SPARQL"
    # timing
    sparql --time --data tyrol$size.nt --query $CURRENT_DIR/$shape.rq --repeat=5 2>&1 1> /dev/null

    # getting fragment
    sparql --data tyrol$size.nt --query $CURRENT_DIR/$shape.rq --results=nt 2> /dev/null > ${shape}sparqlfragment$size.nt

    echo "### pySHACL-fragments"
    totaltime="0.0"
    for run in {1..5}
    do
      # timing
      time=$(python pySHACL-fragments/pyshacl/cli.py tyrol$size.nt -o /dev/null -rs=True -s=$CURRENT_DIR/$shape.cut.ttl -df=nt -sf=turtle 2> /dev/null | head -n 1)

      # getting fragment
      python pySHACL-fragments/pyshacl/cli.py tyrol$size.nt -o ${shape}pyshaclfragment$size.nt -rs=True -s=$CURRENT_DIR/$shape.cut.ttl -df=nt -sf=turtle 2> /dev/null > /dev/null

      totaltime=$(echo "$totaltime+$time" | bc -l)
      echo "Time: $time sec"
    done

    average=$(echo "$totaltime/$run" | bc -l)
    echo "Total time: $totaltime sec for repeat count of $run : average: $average"

    echo "Comparing models: "
    rdfcompare ${shape}sparqlfragment$size.nt ${shape}pyshaclfragment$size.nt
  done
done
