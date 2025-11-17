#!/bin/bash

PATH_TO_CODE="./bins_and_balls"

T=100
M=20
B=(0.0 0.25 0.5 0.75 1.0)
D=(3 7 11 15)
B_SIZE=(20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320 340 360 380 400)
N_LIM=400
strategy="D_Choice"

for j in "${D[@]}"; do
    for i in "${B_SIZE[@]}"; do
        alr --chdir="$PATH_TO_CODE" build -- \
            -gnateDN="$M" -gnateDM="$M" -gnateDSTRAT="$strategy" \
            -gnateDT="$T" -gnateDD="$j" -gnateDK=0 \
            -gnateDBATCH=True -gnateDBATCH_SIZE=$i &>/dev/null
        alr --chdir="$PATH_TO_CODE" run -s > /dev/null

        OUTPUT_FILE="results/${strategy}_${M}_${j}_B_Low.csv"

        if [ "$i" -eq 20 ]; then
            cat "$PATH_TO_CODE/results.csv" > "$OUTPUT_FILE"
        else
            tail -n +2 "$PATH_TO_CODE/results.csv" >> "$OUTPUT_FILE"
        fi
    done
done

echo  
