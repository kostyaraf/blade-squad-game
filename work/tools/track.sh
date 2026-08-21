#!/bin/zsh
# track.sh <input> <startframe> <endframe> <step>
inp=$1; s=$2; e=$3; st=$4
for f in $(seq $s $st $e); do
  ./work/tools/nesemu "Power Blade 2 (USA).nes" -input $inp -frames $f -ramdump /tmp/t_$f.ram >/dev/null 2>&1
done
