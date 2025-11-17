#!/bin/bash

PATH_TO_CODE="./bins_and_balls"

T=100
M=20
D=100
N_LIM=20
strategy="D_Choice"

for i in $(seq 1 "$D")
do
   alr --chdir=$PATH_TO_CODE build -- -gnateDN=$N_LIM -gnateDM=$M -gnateDSTRAT=$strategy -gnateDT=$T  -gnateDD=$i &> /dev/null
   alr --chdir=$PATH_TO_CODE run -s > /dev/null

   OUTPUT_FILE="results/${strategy}_${M}_Low.csv"

   if [ "$i" -eq 1 ]; then
      cat "$PATH_TO_CODE/results.csv" > "$OUTPUT_FILE"
   else
      # Skip the header line and append the rest
      tail -n +2 "$PATH_TO_CODE/results.csv" >> "$OUTPUT_FILE"
   fi
done
