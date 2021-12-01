#!/bin/bash
DIR=~
EXPERIMENT_DIR=$(pwd)

cd DIR

git clone https://github.com/Shape-Fragments/pySHACL-fragments
cd pySHACL-fragments
python3 -m venv .venv
source .venv/bin/activate
pip3 install pyshacl rdflib_jsonld
export PYTHONPATH=$(pwd)
cd ..

for size in {1..5}
do
  curl -o tyrol.nt "https://cloud.ilabt.imec.be/index.php/s/2HiMDZMQAsAKNgc/download?path=/&files=tyrol$size.nt"
done

wget https://dlcdn.apache.org/jena/binaries/apache-jena-4.2.0.tar.gz
tar -xzvf apache-jena-4.2.0.tar.gz
export PATH=$PATH:$DIR/apache-jena-4.2.0/bin
