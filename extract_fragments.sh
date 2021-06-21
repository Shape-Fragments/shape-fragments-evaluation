#!/bin/bash

# directory with query results:
directory=/tmp/shape-views-validation 

# prioritize pyshacl-fragments over any other pyshacl import (e.g. from pip)
# expects pyshacl-fragments repository in sibling directory to this repository
export PYTHONPATH=../pyshacl-fragments

for benchmark in "watdiv" "bsbm"; do
  # iterate over the shapes of this benchmark
  for shape in shapes/$benchmark/*.ttl; do
    # identifier of query/shape
    code=${shape:8+${#benchmark}:${#shape}-12-${#benchmark}}

    echo "###################"
    echo "Extracting fragments for shape $code"
    # expects pyshacl-fragments repository in sibling directory to this repository
    /usr/bin/python3.6 ../pyshacl-fragments/pyshacl/cli.py /tmp/shape-views-validation/$benchmark.nt -o=/tmp/shape-views-validation/$benchmark/$code-shacl.nt -rs=True -s=shapes/$benchmark/$code.ttl -df=nt -sf=turtle -eo=/tmp/shape-views-validation/$benchmark/$code.nt
  done
done
