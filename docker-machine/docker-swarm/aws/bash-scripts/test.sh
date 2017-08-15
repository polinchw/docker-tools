#!/bin/bash

INIT_COMMAND_RESULTS="docker swarm join \
    --token SWMTKN-1-01ifqiy6q1nrq8uh48ajen568058sxz9oo78bge7taxqrfgqqa-ba7swkzlr0segdflxx1r2d81m \
    10.0.1.67:2377"
echo "$INIT_COMMAND_RESULTS"
IFS=' ' read -ra BITS <<< "$INIT_COMMAND_RESULTS"    #Convert string to array
#Print all names from array
for i in "${BITS[@]}"; do
    echo "Bit: " $i
done
echo "Token: " ${BITS[4]}