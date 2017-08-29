#!/bin/bash

lines=$1

if [ -z $lines ]; then
  lines=1
fi

for file in *inp; do
  newpara=`grep -i -A $lines 'new para' ${file%????}*out | tail -$lines`
  oldpara=`grep -i 'wtbspara' $file | sed 's/^.*=//'`
  newpara=`echo $newpara`
  sed -i -e "s/$oldpara/$newpara/" $file
done
