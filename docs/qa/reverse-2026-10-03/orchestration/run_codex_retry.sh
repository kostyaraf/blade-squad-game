#!/bin/zsh
# повтор при перегрузке модели; останавливается при лимите или нормальном завершении
WT=/Users/hropl/pr/mypr/PB3-wt
for i in 1 2 3 4 5 6 7 8 9 10; do
  $WT/run_codex.sh $1 $2
  cp $WT/$1.log $WT/$1.log.$i
  grep -q "at capacity" $WT/$1.log || break
  sleep 180
done
