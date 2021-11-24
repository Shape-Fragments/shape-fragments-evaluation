#!/bin/bash
DIR=~
EXPERIMENT_DIR=$(pwd)

cd DIR

wget https://dlcdn.apache.org/jena/binaries/apache-jena-4.2.0.tar.gz
tar -xzvf apache-jena-4.2.0.tar.gz
export PATH=$PATH:$DIR/apache-jena-4.2.0/bin

wget https://dlcdn.apache.org/jena/binaries/apache-jena-fuseki-4.2.0.tar.gz
tar -xzvf apache-jena-fuseki-4.2.0.tar.gz
export PATH=$PATH:$DIR/apache-jena-fuseki-4.2.0

for year in {2021..2010}
do

