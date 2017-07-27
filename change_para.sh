#!/bin/bash

for file in *inp; do
  newpara=`grep -i -A 1 'new para' ${file%????}*out | tail -1`
  oldpara=`grep -i 'wtbspara' $file | sed 's/^.*=//'`
  sed -i -e "s/$oldpara/$newpara/" $file
done
