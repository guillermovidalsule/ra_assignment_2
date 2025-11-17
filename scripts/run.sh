#!/bin/bash

PATH_TO_CODE="./bins_and_balls"

T=100
M=20
B=(1.0)
N_LIM=400
strategy="Probabilistic"

for j in "${B[@]}"; do
    for i in $(seq 1 "$N_LIM"); do
        alr --chdir="$PATH_TO_CODE" build -- \
            -gnateDN="$i" -gnateDM="$M" -gnateDSTRAT="$strategy" \
            -gnateDT="$T" -gnateDB="$j" -gnateDK=1 &> /dev/null
        alr --chdir="$PATH_TO_CODE" run -s > /dev/null

        OUTPUT_FILE="results/${strategy}_${M}_${j}_1.csv"

        if [ "$i" -eq 1 ]; then
            cat "$PATH_TO_CODE/results.csv" > "$OUTPUT_FILE"
        else
            tail -n +2 "$PATH_TO_CODE/results.csv" >> "$OUTPUT_FILE"
        fi

    done
done

echo  
