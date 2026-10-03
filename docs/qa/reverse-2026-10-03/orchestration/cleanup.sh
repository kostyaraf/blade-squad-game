#!/bin/zsh
# каждые 15 минут: чистка временных файлов QA; сигнал, если свободно < 12 ГБ
WT=/Users/hropl/pr/mypr/PB3-wt
while true; do
  rm -f ~/Library/Application\ Support/Godot/app_userdata/PB3/logs/godot*.log(N)
  rm -f $WT/*.log.<->(N.mmin+120)
  for d in npb pb2work m nova-pb2c sol-pb2c nova-sol2 sol-sol2 npb2b; do
    [ -d $TMPDIR/$d ] && find $TMPDIR/$d -type f -mmin +240 -delete 2>/dev/null
  done
  find /tmp -maxdepth 2 -user $USER -name '*.log' -size +100M -mmin +60 -delete 2>/dev/null
  f=$(df -g /System/Volumes/Data | tail -1 | awk '{print $4}')
  echo "$(date +%H:%M) free=${f}G" >> $WT/cleanup.txt
  [ "$f" -lt 12 ] && { echo "LOW DISK: ${f}G free $(date)"; exit 0; }
  sleep 900
done
