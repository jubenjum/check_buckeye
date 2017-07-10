#!/bin/bash

set -e

# including the input variables from the file config
. config

### run discovery for parameters on the 'config' file
./run_disc   

### run Aren's clustering algorithm
./post_disc 

#### evaluating the results
#mkdir -p ./out
#CORPUS='english' python ./eval2.py -v ${EXPDIR}/${EXPNAME}/results/${MASTER_GRAPH}.class out

