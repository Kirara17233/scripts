#!/usr/bin/zsh

for file in $(ls $1/*.colors| tr " " "_")
do
  mv "`echo $file | sed "s|_|\\\ |g"`" $file
done
